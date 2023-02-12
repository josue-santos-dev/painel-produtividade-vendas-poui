import { Component } from '@angular/core';

import { PoMenuItem } from '@po-ui/ng-components';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css'],
})
export class AppComponent {

  public readonly menus: Array<PoMenuItem> = [
    {
      label: 'DashBoard',
      link: '/home',
      icon: 'po-icon-home',
      shortLabel: 'Dashboard',
    },
    {
      label: 'Produtividade Vendas',
      link: '/produtividade',
      icon: 'po-icon-chart-columns',
      shortLabel: 'Produtividade',
    },

  ];
}
