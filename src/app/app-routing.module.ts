import { ProdutividadeComponent } from './produtividade/produtividade.component';
import { DashBoardComponent } from './dash-board/dash-board.component';
import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

const routes: Routes = [
  { path: 'home', component: DashBoardComponent },
  { path: "produtividade", component: ProdutividadeComponent },
];


@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
