import { ServicesComponent } from './../services/services.component';
import { Component, OnInit, ViewChild } from '@angular/core';
import { PoChartType, PoInputComponent, PoMultiselectFilter } from '@po-ui/ng-components';
import { DatePipe } from '@angular/common';

@Component({
  selector: 'app-dash-board',
  templateUrl: './dash-board.component.html',
  styleUrls: ['./dash-board.component.css'],
})
export class DashBoardComponent implements OnInit {

  filtroPeriodos = this.serviceDash.urlPeriodos;
  dashPositivados: any;
  dashSupervisor: any;
  tipoPositivados: PoChartType = PoChartType.Donut;
  tipoSupervisor: PoChartType = PoChartType.Bar;
  totalClientes:         number = 0;
  totalPositivados:      number = 0;
  totalNPositivados:     number = 0;
  totalNovosClientes:    number = 0;
  totalClientesAtivos:   number = 0;
  totalClientesInativos: number = 0;
  periodoEscolhido = this.datepipe.transform(Date(), 'yyyyMM');
  helpPesquisa: string = `Ex.: ${this.periodoEscolhido}`;
  bloqueiaComponente: boolean = true;
  carregando: boolean = false;

  constructor(private serviceDash: ServicesComponent, private datepipe: DatePipe) {}

  ngOnInit(): void {

    this.carregando = false;

    this.serviceDash.getPositivados(this.periodoEscolhido).subscribe({
      next: (resposta) => {
        this.dashPositivados = resposta;
      },
    });

    this.serviceDash.getSupervisor(this.periodoEscolhido).subscribe({
      next: (resposta) => {
        this.dashSupervisor = resposta;
      },
    });

    this.serviceDash.getQuantidades(this.periodoEscolhido).subscribe({
      next: (retorno) => {

        this.totalClientes         = retorno.items.quantidade_clientes;
        this.totalPositivados      = retorno.items.quantidade_positivados;
        this.totalNPositivados     = retorno.items.quantidade_n_positivados;
        this.totalNovosClientes    = retorno.items.quantidade_novos_clientes;
        this.totalClientesAtivos   = retorno.items.quantidade_clientes_ativos;
        this.totalClientesInativos = retorno.items.quantidade_clientes_inativos;

        this.carregando = true;

      },
    });

  }

  mudancaSair(param: any){
    console.log(param);
    this.periodoEscolhido = param ? param : '';
  }

  atualizarDash(periodo: any){

    this.carregando = false;
    let periodoParametro = periodo ? periodo : this.periodoEscolhido;
    this.totalClientes         = 0;
    this.totalPositivados      = 0;
    this.totalNPositivados     = 0;
    this.totalNovosClientes    = 0;
    this.totalClientesAtivos   = 0;
    this.totalClientesInativos = 0;

    this.serviceDash.getPositivados(periodoParametro).subscribe({
      next: (resposta) => {
        this.dashPositivados = resposta;
      },
    });

    this.serviceDash.getSupervisor(periodoParametro).subscribe({
      next: (resposta) => {
        this.dashSupervisor = resposta;
      },
    });

    this.serviceDash.getQuantidades(periodoParametro).subscribe({
      next: (retorno) => {

        this.totalClientes         = retorno.items.quantidade_clientes;
        this.totalPositivados      = retorno.items.quantidade_positivados;
        this.totalNPositivados     = retorno.items.quantidade_n_positivados;
        this.totalNovosClientes    = retorno.items.quantidade_novos_clientes;
        this.totalClientesAtivos   = retorno.items.quantidade_clientes_ativos;
        this.totalClientesInativos = retorno.items.quantidade_clientes_inativos;

        this.carregando = true;

      },
    });

  }
}
