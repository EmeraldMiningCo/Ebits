// Copyright (c) 2011-2013 The Ebits developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#include "governancedialog.h"
#include "ui_governancedialog.h"
#include <masternode.h>
#include <masternode-sync.h>
#include <masternodeconfig.h>
#include <masternodeman.h>
#include <governance/governance.h>
#include <governance/governance-vote.h>
#include <governance/governance-classes.h>
#include <governance/governance-validators.h>
#include <ebitsunits.h>
#include <guiconstants.h>
#include <guiutil.h>
#include <messagesigner.h>
#include <optionsmodel.h>
#include <walletmodel.h>
#include <validation.h>

#include <QClipboard>
#include <QDrag>
#include <QMenu>
#include <QMimeData>
#include <QMouseEvent>
#include <QPixmap>
#if QT_VERSION < 0x050000
#include <QUrl>
#endif

#if defined(HAVE_CONFIG_H)
#include "config/ebits-config.h" /* for USE_QRCODE */
#endif

#ifdef USE_QRCODE
#include <qrencode.h>
#endif


GovernanceDialog::GovernanceDialog(QWidget *parent) :
        QDialog(parent),
        walletModel(0),
        ui(new Ui::GovernanceDialog),
        model(0)
{
    ui->setupUi(this);
}

GovernanceDialog::~GovernanceDialog()
{
    delete ui;
}

void GovernanceDialog::setModel(OptionsModel *model)
{
    this->model = model;

    if (model)
        connect(model, SIGNAL(displayUnitChanged(int)), this, SLOT(update()));

    // update the display unit if necessary
    update();
}

void GovernanceDialog::setInfo(QString strWindowtitle, QString strQRCode, QString strTextInfo, QString strQRCodeTitle)
{
    this->strWindowtitle = strWindowtitle;
    this->strQRCode = strQRCode;
    this->strTextInfo = strTextInfo;
    this->strQRCodeTitle = strQRCodeTitle;
    update();
}



void GovernanceDialog::setWalletModel(WalletModel *model)
{
    this->walletModel = model;
}



void GovernanceDialog::update()
{
    if(!model)
        return;

    setWindowTitle(strWindowtitle);
    ui->outUri->setText(strTextInfo);

}
