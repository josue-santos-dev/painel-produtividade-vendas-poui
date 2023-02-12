import { Component, OnInit, ViewChild } from '@angular/core';
import {
  PoBreadcrumb,
  PoDynamicFormComponent,
  PoDynamicFormField,
  PoDynamicFormFieldChanged,
  PoDynamicFormValidation,
  PoModalAction,
  PoModalComponent,
  PoPageAction,
  PoTableAction,
  PoTableColumn,
} from '@po-ui/ng-components';
import {
  PoPageDynamicSearchFilters,
  PoPageDynamicSearchLiterals,
  PoPageDynamicTableOptions,
} from '@po-ui/ng-templates';

import { ServicesComponent } from '../services/services.component';
import { DatePipe } from '@angular/common';
import { QueryParamsType } from '@po-ui/ng-components/lib/components/po-table/po-table-base.component';

@Component({
  selector: 'app-produtividade',
  templateUrl: './produtividade.component.html',
  styleUrls: ['./produtividade.component.css'],
  providers: [ServicesComponent],
})
export class ProdutividadeComponent implements OnInit {
  @ViewChild('detalhesModal') detalhesModal!: PoModalComponent;
  @ViewChild('configuracoes') configuracoes!: PoModalComponent;
  @ViewChild('dynamicForm', { static: true })
  dynamicForm!: PoDynamicFormComponent;

  produtividade: Array<object> = [];
  urlSearch: string = this.serviceProdutividade.url;
  loadingTable: boolean = false;
  loadingShowMore: boolean = false;
  showMoreDisabled: boolean = false;
  page: number = 0;
  urlShowMore: string = '';
  pesquisa: string = '';
  filtro: string = '';
  filtrosAplicados = '';
  columns: Array<PoTableColumn> = this.serviceProdutividade.gridcolmunsProdutividade();
  columnsDefault: Array<PoTableColumn> = [];
  serviceApi = this.serviceProdutividade.urlProdutividade;
  status = true;
  actionsRight = false;
  detalheMedicao: any;
  detalheConfig: any;
  quickSearchWidth: number = 4;
  concatenarFiltros: boolean = true;
  loadtable: Array<any> = [];
  teste: any;
  camposComValidacao: Array<string> = ['paginacao'];
  readonly fields: Array<any> = this.serviceProdutividade.gridcolmunsProdutividade();
  readonly detailFields: Array<PoDynamicFormField> =
    this.serviceProdutividade.pageDatails();
  readonly filtroAvancado: Array<PoPageDynamicSearchFilters> =
    this.serviceProdutividade.getFiltroAvancado();

  ngOnInit() {
    this.urlShowMore = this.urlSearch + '/Produtividade';
    //this.buscaAvançada('status=1,2&');
  }

  atualizar() {
    this.loadingShowMore = true;
    this.loadingTable = true;
    this.page = 50;
    let url = this.urlShowMore;

    url +=
      this.pesquisa != ''
        ? `?search=${this.pesquisa}&page=1&pageSize=${this.page}`
        : `?page=1&pageSize=${this.page}`;

    if (this.filtro != '') {
      url += `&${this.filtro}`;
    }

    this.serviceProdutividade.getItemsFilter(url).subscribe(
      (itens) => {
        this.produtividade = itens.items;

        if (itens.hasNext == false) {
          this.showMoreDisabled = true;
        } else {
          this.showMoreDisabled = false;
        }

        this.loadingShowMore = false;
        this.loadingTable = false;
      },
      () => {
        this.status = false;
      }
    );
  }

  fechar: PoModalAction = {
    action: () => {
      this.configuracoes.close();
    },
    label: 'Fechar',
    danger: true,
  };

  confirmar: PoModalAction = {
    action: () => {
      this.atualizar();
      this.configuracoes.close();
    },
    label: 'Confirma',
  };

  public readonly breadcrumb: PoBreadcrumb = {
    items: [
      { label: 'Inicio', link: '' },
      { label: 'Produtividade', link: '/Produtividade' },
    ],
  };

  public readonly actions: Array<PoPageAction> = [
    {
      label: 'Atualizar',
      action: this.atualizar.bind(this),
      icon: 'po-icon-refresh',
    },
  ];

  readonly estruturaFiltroAvancado: PoPageDynamicSearchLiterals = {
    filterConfirmLabel: 'Aplicar',
    filterTitle: 'Filtro avançado',
    quickSearchLabel: 'Valor pesquisado:',
  };

  actionsTable: Array<PoTableAction> = [
    {
      label: 'Detalhes',
      action: this.exibirDetalhes.bind(this),
      icon: 'po-icon po-icon-chart-area',
    },
  ];

  constructor(
    private serviceProdutividade: ServicesComponent,
    private datepipe: DatePipe
  ) {}

  onLoadFields() {
    return this.serviceProdutividade.getFiltroInicial();
  }

  onQuickSearch(filter: any) {
    filter ? this.searchItems(filter) : this.resetFilters();
    this.pesquisa = filter ? filter : '';
  }

  realizaBuscaAvancada(retornoBuscaAvancada: {
    [key: string]: QueryParamsType;
  }): void {
    this.filtro = '';
    for (let atributo in retornoBuscaAvancada) {
      if (retornoBuscaAvancada.hasOwnProperty(atributo)) {
        this.filtro += `${atributo}=${retornoBuscaAvancada[atributo]}&`;
      }
    }
    console.log('Busca avançada => ' + this.filtro);
    this.buscaAvançada(this.filtro);
  }

  private searchItems(filter: any) {
    let url = this.urlSearch + '/Produtividade';

    this.loadingTable = true;
    this.loadingShowMore = true;
    this.page += 50;

    url +=
      filter != ''
        ? `?search=${filter}&page=1&pageSize=${this.page}`
        : `?page=1&pageSize=${this.page}`;

    console.log('url - pesquisa: ' + url);

    this.serviceProdutividade.getItemsFilter(url).subscribe(
      (itens) => {
        this.produtividade = itens.items;

        if (itens.hasNext == false) {
          this.showMoreDisabled = true;
        } else {
          this.showMoreDisabled = false;
        }

        this.loadingTable = false;
        this.loadingShowMore = false;
      },
      () => {
        this.status = false;
      }
    );
  }

  private buscaAvançada(filter: any) {
    let urlbuscaAvancada = this.urlSearch + '/Produtividade';

    this.loadingTable = true;
    this.loadingShowMore = true;
    this.page += 50;

    urlbuscaAvancada +=
      filter != ''
        ? `?${filter}page=1&pageSize=${this.page}`
        : `?page=1&pageSize=${this.page}`;

    console.log('url - Busca Avançada: ' + urlbuscaAvancada);

    this.serviceProdutividade.getItemsFilter(urlbuscaAvancada).subscribe(
      (itens) => {
        this.produtividade = itens.items;

        if (itens.hasNext == false) {
          this.showMoreDisabled = true;
        } else {
          this.showMoreDisabled = false;
        }

        this.loadingShowMore = false;
        this.loadingTable = false;
      },
      () => {
        this.status = false;
      }
    );
  }

  private resetFilters() {
    this.produtividade = this.serviceProdutividade.resetFilterProdutividade();
  }

  restoreColumn() {
    this.columns = this.columnsDefault;
  }

  changeColumnVisible(event: any) {
    localStorage.setItem('initial-columns', event);
  }

  showMore(event: any) {
    this.loadingTable = true;
    this.loadingShowMore = true;
    this.showMoreDisabled = true;
    this.page += 50;
    let url = this.urlShowMore;

    console.log('this.page = ' + this.page);

    url +=
      this.pesquisa != ''
        ? `?search=${this.pesquisa}&page=1&pageSize=${this.page}`
        : `?page=1&pageSize=${this.page}`;

    if (this.filtro != '') {
      url += `&${this.filtro}`;
    }

    console.log(url);

    this.serviceProdutividade.getItemsFilter(url).subscribe(
      (itens) => {
        this.produtividade = itens.items;

        if (itens.hasNext == false) {
          this.showMoreDisabled = true;
        } else {
          this.showMoreDisabled = false;
        }

        this.loadingShowMore = false;
        this.loadingTable = false;
      },
      () => {
        this.status = false;
      }
    );
  }

  clickDisclaimers(e: any[]) {
    this.loadingTable = true;
    this.filtro = '';
    this.page = 50;
    this.pesquisa = '';

    if (e.length === 0) {
      this.serviceProdutividade
        .getItemsFilter(this.urlShowMore + `?page=1&pageSize=${this.page}`)
        .subscribe(
          (itens) => {
            this.produtividade = itens.items;

            if (itens.hasNext == false) {
              this.showMoreDisabled = true;
            } else {
              this.showMoreDisabled = false;
            }

            this.loadingTable = false;
          },
          () => {
            this.status = false;
          }
        );
    } else {
      e.map(
        (disclaimer) =>
          (this.filtrosAplicados += `${disclaimer.property}=${disclaimer.value}&`)
      );

      this.serviceProdutividade
        .getItemsFilter(
          this.urlShowMore +
            `?page=1&pageSize=${this.page}&` +
            this.filtrosAplicados
        )
        .subscribe(
          (itens) => {
            this.produtividade = itens.items;

            if (itens.hasNext == false) {
              this.showMoreDisabled = true;
            } else {
              this.showMoreDisabled = false;
            }

            this.loadingTable = false;
          },
          () => {
            this.status = false;
          }
        );
    }
  }

  private exibirDetalhes(medicao: any) {
    this.detalheMedicao = medicao;

    this.detalhesModal.open();
  }

}
