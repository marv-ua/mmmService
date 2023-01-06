﻿
Процедура ПриКомпоновкеРезультата(ДокументРезультат, ДанныеРасшифровки, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	НастройкиКомпоновки = КомпоновщикНастроек.ПолучитьНастройки();
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
	МакетКомпоновки = КомпоновщикМакета.Выполнить(СхемаКомпоновкиДанных, НастройкиКомпоновки, ДанныеРасшифровки,,,,);
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
	//вн = Отчеты.ВНД.ВнешниеНаборыДанных(ПараметрыПериод.Значение.ДатаНачала, ПараметрыПериод.Значение.ДатаОкончания, Организации);
	вн = ВнешниеНаборыДанныхФоном(ПараметрыПериод.Значение.ДатаНачала, ПараметрыПериод.Значение.ДатаОкончания, Организации);
	
	ПроцессорКомпоновкиДанных.Инициализировать(МакетКомпоновки, вн, ДанныеРасшифровки, Истина, Ложь,);
	//количество аргументов различается в разных релизах платформы ?
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВТабличныйДокумент;
	ПроцессорВывода.УстановитьДокумент(ДокументРезультат);
	ПроцессорВывода.Вывести(ПроцессорКомпоновкиДанных);
	
КонецПроцедуры

Функция ВнешниеНаборыДанныхФоном(ДатаНач, ДатаКон, Организация)

	Ключ = "ВнешниеНаборыДанных_Отчет_ВНД" + СтрЗаменить(Новый УникальныйИдентификатор, "-","");

	//Подготовим адрес в хранилище
	АдресВХранилище = ПоместитьВоВременноеХранилище(Неопределено);
	ВходящиеПараметры = Новый Структура;
	ВходящиеПараметры.Вставить("ДатаНач", ДатаНач);
	ВходящиеПараметры.Вставить("ДатаКон", ДатаКон);
	ВходящиеПараметры.Вставить("Организация", Организация);

	МассивПараметров = Новый Массив;
	МассивПараметров.Добавить(ВходящиеПараметры);
	МассивПараметров.Добавить(АдресВХранилище);

	ФоновыеЗадания.Выполнить("мммСервер.ВнешниеНаборыДанныхЗапускВыполнения", МассивПараметров, Ключ, "ВнешниеНаборыДанных_Отчет_ВНД");

	МассивЗаданий = ФоновыеЗадания.ПолучитьФоновыеЗадания(Новый Структура("Ключ", Ключ));
	
	Для Каждого Задание Из МассивЗаданий Цикл  
		Задание = Задание.ОжидатьЗавершенияВыполнения();
		
		Если Задание.Состояние = СостояниеФоновогоЗадания.Завершено Тогда
			Результат = ПолучитьИзВременногоХранилища(АдресВХранилище);
			Возврат Результат;
		ИначеЕсли Задание.Состояние = СостояниеФоновогоЗадания.ЗавершеноАварийно ИЛИ Задание.Состояние = СостояниеФоновогоЗадания.Отменено Тогда
			Возврат Новый Структура("ВнешнийНабор", Отчеты.ВНД.ОписаниеТаблицыРезультата());
		ИначеЕсли Задание.Состояние = СостояниеФоновогоЗадания.Активно Тогда
		КонецЕсли;
	КонецЦикла;

КонецФункции