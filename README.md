# 🛡️ Procedimento de Sanitização de Máquinas

## Visão Geral

Esta solução foi desenvolvida para automatizar o processo de sanitização de discos utilizando o **Active@ KillDisk**.

Após a inicialização pelo pendrive, a sanitização é executada automaticamente. Ao final do processo, um certificado é gerado e salvo na pasta `CERTIFICADOS` do próprio dispositivo, facilitando o armazenamento e o controle dos registros.

## Como Utilizar

### Preparação do Pendrive:

1. Obtenha a ISO do Active@ KillDisk.
2. Crie um pendrive bootável utilizando a ISO.
3. Copie os arquivos `BootDisk_Scripts` e `_bootDisk.ini` para a raiz do pendrive.


### Execução:

1. Conecte o pendrive à máquina que será sanitizada.
2. Inicialize o equipamento pelo pendrive.
3. Caso seja solicitada a senha do Active@ KillDisk, informe-a.
4. O processo de sanitização será iniciado automaticamente.

**IMPORTANTE: Durante a execução, basta acompanhar o progresso e aguardar a conclusão.**

### Certificado:

Ao término da sanitização, o certificado será gerado automaticamente e armazenado na pasta:

```text
CERTIFICADOS
```

Recomenda-se realizar uma cópia do arquivo para fins de auditoria e controle interno.

## Observações:

* O tempo de execução varia de acordo com a capacidade e o desempenho do disco.
* Mantenha o equipamento conectado à energia durante todo o processo.
* Não desligue a máquina nem remova o pendrive antes da conclusão da sanitização.
* Verifique se o pendrive foi criado corretamente e contém todos os arquivos necessários.

## Benefícios:

* Processo totalmente automatizado.
* Menor intervenção operacional.
* Padronização da sanitização.
* Geração automática de certificados.
* Organização centralizada dos registros.

## Créditos

**Desenvolvido por:** Eduardo Silva Moraes<br/>
**Contato:** [contact@eduu.dev](mailto:contact@eduu.dev)
