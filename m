From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next] qede: allocate enough data for ->arfs_fltr_bmap
Date: Wed, 19 Apr 2017 10:12:44 +0000
Message-ID: <BL2PR07MB23064ACD404C3789B1E7DDC28D180@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <20170419095432.GA4266@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "Elior, Ariel" <Ariel.Elior@cavium.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
        "Chopra@mwanda" <Chopra@mwanda>
To: Dan Carpenter <dan.carpenter@oracle.com>,
        "Chopra, Manish" <Manish.Chopra@cavium.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170419095432.GA4266@mwanda>
Content-Language: en-US
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> We've got the number of longs, yes, but we should multiply by
> sizeof(long) to get the number of bytes needed.
>=20
> Fixes: e4917d46a653 ("qede: Add aRFS support")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Thanks Dan.

Acked-by: Yuval Mintz <Yuval.Mintz@cavium.com>
