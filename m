From: Adit Ranadive <aditr-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
Subject: RE: [PATCH v4 01/16] vmxnet3: Move PCI Id to pci_ids.h
Date: Wed, 14 Sep 2016 16:00:25 +0000
Message-ID: <DM2PR0501MB844852987661859C6654E40C5F10@DM2PR0501MB844.namprd05.prod.outlook.com>
References: <1473655766-31628-1-git-send-email-aditr@vmware.com>
 <1473655766-31628-2-git-send-email-aditr@vmware.com>
 <20160914110854.GA15800@yuval-lap.uk.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        pv-drivers <pv-drivers-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "Jorgen S. Hansen" <jhansen-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>,
        Aditya Sarwade <asarwade-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>,
        George Zhang <georgezhang-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>,
        Bryan Tan <bryantan-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
To: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160914110854.GA15800-Hxa29pjIrETlQW142y8m19+IiqhCXseY@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 14, 2016 at 04:09:12 -0700, Yuval Shaia wrote:
> Please update vmxnet3_drv.c accordingly.

Any reason why? I don't think we need to. Vmxnet3 should just pick up the m=
oved
PCI device id from pci_ids.h file.

- Adit
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
