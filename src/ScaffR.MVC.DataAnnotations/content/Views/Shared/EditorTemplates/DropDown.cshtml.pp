﻿@using $rootnamespace$.Extensions
@model object

@Html.DropDownListFor(m => m, Html.GetAutomatedList(m => m).SetSelected(Model))