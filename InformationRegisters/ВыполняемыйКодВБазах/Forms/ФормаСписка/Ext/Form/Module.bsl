﻿#Область СобытияФормы
#КонецОбласти

#Область СобытияЭлементовФормы
&НаКлиенте
Процедура СписокВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	Если Элемент.ТекущийЭлемент.Имя = "Статус" Тогда
		СтандартнаяОбработка = Ложь;
		
		ПоказатьВопрос(Новый ОписаниеОповещения("ВыполнитьДействиеВопрос", ЭтотОбъект, ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(Элементы.Список.ТекущиеДанные)),
			"Выполнить действие?", 
			РежимДиалогаВопрос.ДаНет
		);	
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ЗапуститьВыполнение(Команда)
	ПоказатьВопрос(Новый ОписаниеОповещения("ВыполнитьДействиеВопрос", ЭтотОбъект, Элементы.Список.ВыделенныеСтроки),
		"Выполнить действие?",
		РежимДиалогаВопрос.ДаНет
	);	
КонецПроцедуры

&НаКлиенте
Процедура СоздатьЗаписи(Команда)
	ОткрытьФорму("РегистрСведений.ВыполняемыйКодВБазах.Форма.ФормаСоздания");
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ВыполнитьДействиеВопрос(Ответ, ДопПараметры) Экспорт
	
	Если Ответ = КодВозвратаДиалога.Да Тогда
		ДлительнаяОперация = НачатьВыполнениеНаСервере(ДопПараметры);
		ОповещениеОЗавершении = Новый ОписаниеОповещения("ОбработатьРезультат", ЭтотОбъект);
		ПараметрыОжидания = ДлительныеОперацииКлиент.ПараметрыОжидания(ЭтотОбъект);
		ДлительныеОперацииКлиент.ОжидатьЗавершение(ДлительнаяОперация, ОповещениеОЗавершении, ПараметрыОжидания);	
	КонецЕсли;	
	
КонецПроцедуры	

&НаСервере
Функция НачатьВыполнениеНаСервере(ДопПараметры)
	
	Массив = Новый Массив;
	Для Каждого Эл Из ДопПараметры Цикл
		
		Эл1 = Неопределено;
		Если ТипЗнч(Эл) = Тип("РегистрСведенийКлючЗаписи.ВыполняемыйКодВБазах") Тогда
			Эл1 = ПолучитьЗаписьПоКлючу(Эл);
		Иначе
			Эл1 = Эл;
		КонецЕсли;	
		
		Массив.Добавить(Новый Структура("Период,Организация,Код,Статус", Эл1.Период, Эл1.Организация, Эл1.Код, Эл1.Статус)
		);
	КонецЦикла;	
	
	ПараметрыВыполнения = ДлительныеОперации.ПараметрыВыполненияПроцедуры();
	ПараметрыВыполнения.ЗапуститьВФоне = Истина;
	Возврат ДлительныеОперации.ВыполнитьПроцедуру(ПараметрыВыполнения, "УдаленноеВыполнениеКода.ВыполнитьКодУдаленно", 
		Массив
	);
КонецФункции
	
&НаКлиенте
Процедура ОбработатьРезультат(Результат, ДополнительныеПараметры) Экспорт
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	Элементы.Список.Обновить();
КонецПроцедуры

&НаСервере
Функция ПолучитьЗаписьПоКлючу(КлючЗаписи) Экспорт
	
	Запись = РегистрыСведений.ВыполняемыйКодВБазах.СоздатьМенеджерЗаписи();
	ЗаполнитьЗначенияСвойств(Запись, КлючЗаписи);
	Запись.Прочитать();
	
	Возврат Запись;
	
КонецФункции

#КонецОбласти