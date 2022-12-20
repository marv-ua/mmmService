﻿
Процедура ПриКомпоновкеРезультата(ДокументРезультат, ДанныеРасшифровки, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	НастройкиКомпоновки = КомпоновщикНастроек.ПолучитьНастройки();	
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
	МакетКомпоновки = КомпоновщикМакета.Выполнить( СхемаКомпоновкиДанных, НастройкиКомпоновки, ДанныеРасшифровки );	
	ПроцессорКомпоновкиДанных = Новый ПроцессорКомпоновкиДанных;
	
	ПараметрыПериод = НастройкиКомпоновки.ПараметрыДанных.Элементы.Найти("Период");
	ПараметрыОрганизация = НастройкиКомпоновки.ПараметрыДанных.Элементы.Найти("Организация");
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Организации", ПараметрыОрганизация.Значение);
	Запрос.Текст = "ВЫБРАТЬ
	               |	Организации.Ссылка КАК Организация
	               |ИЗ
	               |	Справочник.Организации КАК Организации
	               |ГДЕ
	               |	Организации.Ссылка В ИЕРАРХИИ(&Организации)
	               |	И НЕ Организации.ЭтоГруппа";
	Организации = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Организация");
	вн = ВнешниеНаборыДанных(ПараметрыПериод.Значение.ДатаНачала, ПараметрыПериод.Значение.ДатаОкончания, Организации);	
	
	ПроцессорКомпоновкиДанных.Инициализировать(МакетКомпоновки, вн, ДанныеРасшифровки, Истина, Ложь);
	//количество аргументов различается в разных релизах платформы ?
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВТабличныйДокумент;
	ПроцессорВывода.УстановитьДокумент(ДокументРезультат);
	ПроцессорВывода.Вывести(ПроцессорКомпоновкиДанных);
	
КонецПроцедуры

Функция ВнешниеНаборыДанных(ДатаНач, ДатаКон, Организация)
	
	тз = новый ТаблицаЗначений;
	тз.Колонки.Добавить("Счет", Новый ОписаниеТипов("Строка"));
	тз.Колонки.Добавить("Организация");
	тз.Колонки.Добавить("Субконто1", Новый ОписаниеТипов("Строка"));
	тз.Колонки.Добавить("Группа", Новый ОписаниеТипов("Строка"));
	тз.Колонки.Добавить("СуммаНачальныйОстаток", Новый ОписаниеТипов("Число"));
	тз.Колонки.Добавить("СуммаОборотДт", Новый ОписаниеТипов("Число"));
	тз.Колонки.Добавить("СуммаОборотКт", Новый ОписаниеТипов("Число"));
	тз.Колонки.Добавить("СуммаКонечныйОстаток", Новый ОписаниеТипов("Число"));
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Организации.Ссылка КАК Ссылка,
	|	РасположениеФирмСрезПоследних.Сервер КАК Сервер,
	|	РасположениеФирмСрезПоследних.ИмяБазы КАК База,
	|	РасположениеФирмСрезПоследних.Логин КАК Логин,
	|	РасположениеФирмСрезПоследних.Пароль КАК Пароль
	|ИЗ
	|	Справочник.Организации КАК Организации
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.РасположениеФирм.СрезПоследних КАК РасположениеФирмСрезПоследних
	|		ПО Организации.Ссылка = РасположениеФирмСрезПоследних.Организация
	|ГДЕ
	|	Организации.ПометкаУдаления = ЛОЖЬ";
	Если ЗначениеЗаполнено(Организация) Тогда
		Запрос.Текст = Запрос.Текст + "
		|	И Организации.Ссылка В (&Ссылка)";
		Запрос.УстановитьПараметр("Ссылка", Организация);
	КонецЕсли;	
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	ТекПодключение = Новый Структура("Прокси,Сервер,База,Логин,Пароль", Неопределено, "","","","");
	Прогон = 1;
	МассивОрганизацийСОшибками = Новый Массив;
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		ДлительныеОперации.СообщитьПрогресс(Окр(100*Прогон/ВыборкаДетальныеЗаписи.Количество()), СокрЛП(ВыборкаДетальныеЗаписи.Ссылка.НаименованиеСокращенное),);
		Если НЕ ЗначениеЗаполнено(ВыборкаДетальныеЗаписи.Сервер)
			ИЛИ НЕ ЗначениеЗаполнено(ВыборкаДетальныеЗаписи.База)
			ИЛИ НЕ ЗначениеЗаполнено(ВыборкаДетальныеЗаписи.Логин) Тогда
			Продолжить;
		КонецЕсли;	
		
		Актуальность = РегистрыСведений.АктуальностьОрганизаций.ПолучитьПоследнее(ДатаКон, Новый Структура("Организация", ВыборкаДетальныеЗаписи.Ссылка));
		Если НЕ Актуальность.Активна Тогда 
			Продолжить;
		КонецЕсли;	
		
		Попытка
			СоединениеУстановлено = Ложь;
			Для сч = 1 По 3 Цикл
				Попытка
					Прокси = мммСервер.ПолучитьПрокси(ВыборкаДетальныеЗаписи.Сервер, 
						ВыборкаДетальныеЗаписи.База,
						ВыборкаДетальныеЗаписи.Логин,
						ВыборкаДетальныеЗаписи.Пароль
					);
					СоединениеУстановлено = Истина;
					Прервать;
				Исключение
				КонецПопытки;		
			КонецЦикла;
			Если НЕ СоединениеУстановлено Тогда
				Продолжить;
			КонецЕсли;	
			
			///////////////////////////////////////////////////////////////////
			ОСКД = Отчеты.ВНД.ПолучитьМакет("ВНД");	
			
			// сериализуем
			ЗаписьXML = Новый ЗаписьXML;
			ЗаписьXML.УстановитьСтроку();
			СериализаторXDTO.ЗаписатьXML(ЗаписьXML, ОСКД);
			стрОСКД = ЗаписьXML.Закрыть();				
			
			ВыполняемыйКод = СтрШаблон("
				|// десериализуем макет
				|ЧтениеXML = Новый ЧтениеXML;
				|ЧтениеXML.УстановитьСтроку(""%1"");
				|ОСКД = СериализаторXDTO.ПрочитатьXML(ЧтениеXML);
				|
				|НастройкиОСКД = ОСКД.НастройкиПоУмолчанию;
				|
				|ТаблДокум = Новый ТаблицаЗначений;
				|ПараметрыДанныхОСКД = НастройкиОСКД.ПараметрыДанных.Элементы;
				|ЭлементОрганизация = ПараметрыДанныхОСКД.Найти(""Организация"");
				|ЭлементОрганизация.Использование = Истина;
				|ЭлементОрганизация.Значение = Справочники.Организации.НайтиПоРеквизиту(""ИНН"", ""%2"");
				|
				|ЭлементНачалоПериода = ПараметрыДанныхОСКД.Найти(""ПериодНач"");
				|ЭлементНачалоПериода.Использование = Истина;
				|ЭлементНачалоПериода.Значение = НачалоДня(Дата(%3));
				|
				|ЭлементКонецПериода = ПараметрыДанныхОСКД.Найти(""ПериодКон"");
				|ЭлементКонецПериода.Использование = Истина;
			//	|ЭлементКонецПериода.Значение = Новый Граница(КонецДня(Дата(%4)),ВидГраницы.Включая);					
				|ЭлементКонецПериода.Значение = КонецДня(Дата(%4));					
				|
				|КомпоновщикМакетаОСКД = Новый КомпоновщикМакетаКомпоновкиДанных;
				|Макет = КомпоновщикМакетаОСКД.Выполнить(ОСКД, НастройкиОСКД,,, Тип(""ГенераторМакетаКомпоновкиДанныхДляКоллекцииЗначений""));
				|
				|ПроцессорКомпоновкиОСКД = Новый ПроцессорКомпоновкиДанных;
				|ПроцессорКомпоновкиОСКД.Инициализировать(Макет);
				|
				|ПроцессорВыводаОСКД = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВКоллекциюЗначений;
				|ПроцессорВыводаОСКД.УстановитьОбъект(ТаблДокум);
				|ПроцессорВыводаОСКД.Вывести(ПроцессорКомпоновкиОСКД);
				|
				|
				|ВозвращаемоеЗначение = ТаблДокум;
				|"
				, СтрЗаменить(СтрЗаменить(стрОСКД,"""",""""""), Символы.ПС, Символы.ПС+"|")
				, ВыборкаДетальныеЗаписи.Ссылка.ИНН
				, Формат(ДатаНач, "ДФ=yyyy,MM,dd")
				, Формат(ДатаКон, "ДФ=yyyy,MM,dd")
			);  
			
			Ответ = мммСервер.ДеСериализовать(
				Прокси.RunCode(ВыполняемыйКод)
			);
			
			Если НЕ Ответ.Ошибка Тогда
				//ЧтениеXML = Новый ЧтениеXML;
				//ЧтениеXML.УстановитьСтроку(Ответ.Результат);
				//ТабДок = СериализаторXDTO.ПрочитатьXML(ЧтениеXML);		
				
				Если ТипЗнч(Ответ.Результат) = Тип("ТаблицаЗначений") Тогда
					Для Каждого Стр Из Ответ.Результат Цикл
						Если ПустаяСтрока(Стр.Счет) Тогда
							Продолжить;
						КонецЕсли;	
						
						НоваяСтрока = тз.Добавить();
						ЗаполнитьЗначенияСвойств(НоваяСтрока, Стр);
						НоваяСтрока.Организация = ВыборкаДетальныеЗаписи.Ссылка;
					КонецЦикла;
				КонецЕсли;
			КонецЕсли;
			///////////////////////////////////////////////////////////////////			
			
		Исключение
			//МассивОрганизацийСОшибками.Добавить(ВыборкаДетальныеЗаписи.Ссылка);
			Сообщить(СтрШаблон("Не удалось выполнить запрос по организации %1", ВыборкаДетальныеЗаписи.Ссылка));
			ЗаписьЖурналаРегистрации("Отчет затраты", УровеньЖурналаРегистрации.Ошибка, ,,ОписаниеОшибки());
		КонецПопытки;
		Прогон = Прогон + 1;
	КонецЦикла;
	
	Возврат Новый Структура("ВнешнийНабор", тз);
		
	
КонецФункции	
