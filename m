From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/2] ipv4 routing: splitting of ip_route_[in|out]put_slow,
 2.6.10-rc3
Date: Mon, 20 Dec 2004 15:02:16 +0100
Message-ID: <41C6DB68.30607@trash.net>
References: <41C6B3D4.6060207@einar-lueck.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261497AbULTMl6@vger.kernel.org>
To: =?ISO-8859-1?Q?Einar_L=FCck?= <lkml@einar-lueck.de>
In-Reply-To: <41C6B3D4.6060207@einar-lueck.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Einar L=FCck wrote:
> [PATCH 1/2] ipv4 routing: splitting of ip_route_[in|out]put_slow,=20
> 2.6.10-rc3
>=20
> From: Einar Lueck <lkml@einar-lueck.de>
>=20
> This patch splits up ip_route_[in|out]put_slow in inlined functions.
> Basic idea:
> * improve overall comprehensibility
> * allow for an easier application of patch for improved multipath=20
>  support (refer to the subsequent patch)
>=20
> Please consider for application.

Your patches have once again been made unreadable by
your email-client. Please send them again as attachments.

Regards
Patrick
