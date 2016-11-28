From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next] hv_netvsc: remove excessive logging on MTU
 change
Date: Mon, 28 Nov 2016 17:33:25 +0000
Message-ID: <BLUPR03MB1412AA0A828CCEF5E7210C85CA8A0@BLUPR03MB1412.namprd03.prod.outlook.com>
References: <20161128172544.2491-1-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "KY Srinivasan" <kys@microsoft.com>
To: Vitaly Kuznetsov <vkuznets@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161128172544.2491-1-vkuznets@redhat.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Vitaly Kuznetsov [mailto:vkuznets@redhat.com]
> Sent: Monday, November 28, 2016 12:26 PM
> To: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org; KY Srinivasan <kys@microsoft.com>;
> Haiyang Zhang <haiyangz@microsoft.com>
> Subject: [PATCH net-next] hv_netvsc: remove excessive logging on MTU
> change
>=20
> When we change MTU or the number of channels on a netvsc device we get
> the
> following logged:
>=20
>  hv_netvsc bf5edba8...: net device safe to remove
>  hv_netvsc: hv_netvsc channel opened successfully
>  hv_netvsc bf5edba8...: Send section size: 6144, Section count:2560
>  hv_netvsc bf5edba8...: Device MAC 00:15:5d:1e:91:12 link state up
>=20
> This information is useful as debug at most.
>=20
> Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>

Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
