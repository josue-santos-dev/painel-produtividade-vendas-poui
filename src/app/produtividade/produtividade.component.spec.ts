import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ProdutividadeComponent } from './produtividade.component';

describe('ProdutividadeComponent', () => {
  let component: ProdutividadeComponent;
  let fixture: ComponentFixture<ProdutividadeComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ ProdutividadeComponent ]
    })
    .compileComponents();

    fixture = TestBed.createComponent(ProdutividadeComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
