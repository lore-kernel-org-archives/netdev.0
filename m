From: Madalin-cristian Bucur <madalin.bucur@nxp.com>
Subject: RE: [PATCH net-next] fsl/fman: implement several errata workarounds
Date: Fri, 11 Aug 2017 08:41:33 +0000
Message-ID: <AM5PR0402MB269188FDE87431467E6C4076EC890@AM5PR0402MB2691.eurprd04.prod.outlook.com>
References: <1502372824-30180-1-git-send-email-florinel.iordache@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>
To: Florinel Iordache <florinel.iordache@nxp.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502372824-30180-1-git-send-email-florinel.iordache@nxp.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Florinel Iordache [mailto:florinel.iordache@nxp.com]
> Subject: [PATCH net-next] fsl/fman: implement several errata workarounds
>=20
> Implemented workarounds for the following dTSEC Erratum:
> A002, A004, A0012, A0014, A004839 on several operations
> that involve MAC CFG register changes: adjust link,
> rx pause frames, modify MAC address.
>=20
> Signed-off-by: Florinel Iordache <florinel.iordache@nxp.com>

Acked-by: Madalin Bucur <madalin.bucur@nxp.com>
