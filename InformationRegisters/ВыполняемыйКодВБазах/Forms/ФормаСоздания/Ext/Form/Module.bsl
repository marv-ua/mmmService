﻿&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Статус = ЗатратыКлиентСервер.СтатусОтправки_НеОтправлено();
	Период = ТекущаяДата();
	
КонецПроцедуры

&НаСервере
Процедура ЗаписатьНаСервере()
	
	Если Организации.Количество() <> 0 Тогда
		
		Набор = РегистрыСведений.ВыполняемыйКодВБазах.СоздатьНаборЗаписей();
		Для Каждого Организация Из Организации Цикл
			Запись = Набор.Добавить();
			Запись.Статус = Статус;
			Запись.Период = Период;
			Запись.Организация = Организация.Значение;
			Запись.Код = Код;
		КонецЦикла;	
		Набор.Записать(Ложь);
	КонецЕсли;	
	
КонецПроцедуры

&НаКлиенте
Процедура Записать(Команда)
	ЗаписатьНаСервере();
	ЭтаФорма.Закрыть();
КонецПроцедуры

