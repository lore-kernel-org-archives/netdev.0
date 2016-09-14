From: Adit Ranadive <aditr@vmware.com>
Subject: Re: [PATCH v4 00/16] Add Paravirtual RDMA Driver
Date: Wed, 14 Sep 2016 19:44:45 +0000
Message-ID: <DM2PR0501MB844473AE0FCAD0FD748D43DC5F10@DM2PR0501MB844.namprd05.prod.outlook.com>
References: <1473655766-31628-1-git-send-email-aditr@vmware.com>
 <20160912180251.GH5843@obsidianresearch.com>
 <BLUPR0501MB836ED564F2AE7AB9221AC25C5FF0@BLUPR0501MB836.namprd05.prod.outlook.com>
 <20160914173636.GA10309@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "dledford@redhat.com" <dledford@redhat.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        pv-drivers <pv-drivers@vmware.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
        "Jorgen S. Hansen" <jhansen@vmware.com>,
        Aditya Sarwade <asarwade@vmware.com>,
        George Zhang <georgezhang@vmware.com>,
        Bryan Tan <bryantan@vmware.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20160914173636.GA10309@obsidianresearch.com>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 14, 2016 at 10:37:00 -0700, Jason Gunthorpe wrote:
> We desire to use this as the vehical for the userspace included with the =
4.9
> kernel.
>=20
> I anticipate the tree will be running by Oct 1.

Thanks. So does this mean that the libraries distributed via OFED (openfabr=
ics.org)
will be now from the rdma-plumbing git tree?
Or is the switch to happen only when distros start shipping with the 4.9 ke=
rnel by
default?
