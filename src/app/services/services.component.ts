import { environment } from './../../environments/environment';
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { PoMultiselectOption } from '@po-ui/ng-components';
import { map, Observable } from 'rxjs';
import { DatePipe } from '@angular/common';


@Injectable({
  providedIn: 'root',
})
export class ServicesComponent {

  url: string              = environment.url;
  urlProdutividade: string = environment.urlProdutividade;
  urlPeriodos: string      = environment.urlPeriodos;
  urlPositivados: string   = environment.urlPercPositivados;
  urlSupervisor: string    = environment.urlPercSupervisor;
  urlQuantidades: string   = environment.urlQuantidades;

  filtroInicial = this.datepipe.transform(Date(), 'yyyyMM')

  constructor(private http: HttpClient, private datepipe: DatePipe) {}

  public getPositivados(_periodoEscolhido: any): Observable<any> {
    return this.http.get<any>(`${this.urlPositivados}?periodo=${_periodoEscolhido}`);
  }

  public getSupervisor(_periodoEscolhido: any): Observable<any> {
    return this.http.get<any>(`${this.urlSupervisor}?periodo=${_periodoEscolhido}`);
  }

  public getQuantidades(_periodoEscolhido: any): Observable<any> {
    return this.http.get<any>(`${this.urlQuantidades}?periodo=${_periodoEscolhido}`);
  }

  public getFiltroAvancado() {
    return [
      {
        property: 'periodo',
        label: 'Período',
        gridColumns: 6,
      },
      {
        property: 'cod_vendedor',
        label: 'Vendedor(Código)',
        gridColumns: 6,
      },
      {
        property: 'status',
        label: 'Status',
        optionsMulti: true,
        options: [
          {
            value: '1',
            label: 'ABERTO',
          },
          {
            value: '2',
            label: 'FECHADO',
          },
        ],
        gridColumns: 6,
      },
    ];
  }

  public gridcolmunsProdutividade() {
    return [
      {
        property: 'periodo',
        visible: true,
        filter: true,
        optionsMulti: true,
        label: 'Período',
      },
      {
        property: 'cod_vendedor',
        label: 'Codigo Vendedor',
        filter: false,
      },

      {
        property: 'nome_vendedor',
        label: 'Nome Vendedor',
        filter: false,
      },
      {
        property: 'qtd_clientes',
        label: 'Qtd. Clientes',
        filter: false,
      },
      {
        property: 'qtd_positivados',
        label: 'Qtd. Positivados',
        filter: false,
      },
      {
        property: 'qtd_npositivados',
        label: 'Qtd. N/ Positivados',
        filter: false,
      },
      {
        property: 'qtd_novos_clientes',
        label: 'Qtd. Novos Clientes',
        filter: false,
      },
      {
        property: 'qtd_clientes_ativos',
        label: 'Clientes Ativos',
        filter: false,
      },
      {
        property: 'qtd_clientes_inativos',
        label: 'Clientes Inativos',
        filter: false,
      },
      {
        property: 'status',
        label: 'Status',
        filter: false,
        type: 'label',
        labels: [
          {
            value: '1',
            color: 'color-10',
            label: 'ABERTO',
            content: '1',
          },
          {
            value: '2',
            color: 'color-07',
            label: 'FECHADO',
            content: '2',
          },
        ],
      },
    ];
  }

  readonly periodOptions: Array<PoMultiselectOption> = [
    {
      value: '1',
      label: 'ABERTO',
    },
    {
      value: '2',
      label: 'FECHADO',
    },
  ];

  public pageDatails() {
    return [
      {
        property: 'descricao_status',
        label: 'Status',
        tag: true,
        inverse: true,
        divider: 'Erros',
        icon: 'po-icon-ok',
        gridColumns: 12,
        color: 'color-03',
        readonly: true,
      },
      {
        property: 'mensagem_erro',
        label: 'Mensagem do Erro',
        gridColumns: 12,
        rows: 5,
        readonly: true,
      },
      {
        property: 'codigo_medicao',
        label: 'Medição',
        divider: 'Dados de Faturamento - Protheus',
        readonly: true,
      },
      {
        property: 'pedido_de_venda',
        label: 'Pedido de Venda',
        readonly: true,
      },
      { property: 'nota_fiscal', label: 'Nota Fiscal', readonly: true },
      { property: 'rps', label: 'RPS', readonly: true },
      {
        property: 'aceite_enviado',
        label: 'Aceite Enviado',
        divider: 'Envio de Aceite para o SIGEC',
        readonly: true,
        gridColumns: 2,
        options: [
          { aceite_enviado: 'Sim', code: 'S' },
          { aceite_enviado: 'Não', code: 'N' },
        ],
        fieldLabel: 'aceite_enviado',
        fieldValue: 'code',
      },
      {
        property: 'request_aceite',
        label: 'Request Aceite',
        rows: 3,
        gridColumns: 5,
        readonly: true,
      },
      {
        property: 'response_aceite',
        label: 'Response Aceite',
        rows: 3,
        gridColumns: 5,
        readonly: true,
      },
      {
        property: 'nf_enviada',
        label: 'Nota Fiscal Enviada',
        divider: 'Envio de Nota Fiscal para o SIGEC',
        gridColumns: 2,
        readonly: true,
        options: [
          { nf_enviada: 'Sim', code: 'S' },
          { nf_enviada: 'Não', code: 'N' },
        ],
        fieldLabel: 'nf_enviada',
        fieldValue: 'code',
      },
      {
        property: 'request_nf',
        label: 'Request Nota Fiscal',
        rows: 3,
        gridColumns: 5,
        readonly: true,
      },
      {
        property: 'response_nf',
        label: 'Response Nota Fiscal',
        rows: 3,
        gridColumns: 5,
        readonly: true,
      },
      {
        property: 'cancelamento_enviado',
        label: 'Cancelamento Enviado',
        divider: 'Envio de Cancelamento para o SIGEC',
        gridColumns: 2,
        options: [
          { cancelamento_enviado: 'Sim', code: 'S' },
          { cancelamento_enviado: 'Não', code: 'N' },
        ],
        fieldLabel: 'cancelamento_enviado',
        fieldValue: 'code',
        readonly: true,
      },
      {
        property: 'request_cancelamento',
        label: 'Request Cancelamento',
        rows: 3,
        gridColumns: 5,
        readonly: true,
      },
      {
        property: 'response_cancelamento',
        label: 'Response Cancelamento',
        rows: 3,
        gridColumns: 5,
        readonly: true,
      },
    ];
  }

  getItemsProdutividade(): Observable<any> {
    return this.http.get(this.urlProdutividade);
  }

  resetFilterProdutividade() {
    return [this.getItemsProdutividade()];
  }

  getItemsFilter(url: any): Observable<any> {
    return this.http.get(url);
  }

  getFiltroInicial() {
    return {
      filters: [{ property: 'periodo', initValue: this.filtroInicial }],
      keepFilters: true,
    };
  }

  getFiltroPeriodos(): Observable<any> {
    return this.http.get(this.urlPeriodos);
  }
}
