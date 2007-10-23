From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH RESEND] ip_gre: sendto/recvfrom NBMA address
Date: Tue, 23 Oct 2007 16:33:28 +0200
Message-ID: <471E0638.9040405@trash.net>
References: <471E05BD.7040407@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: =?ISO-8859-15?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47263 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751819AbXJWOe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 10:34:27 -0400
In-Reply-To: <471E05BD.7040407@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Timo Ter=E4s wrote:
> When GRE tunnel is in NBMA mode, this patch allows an application to =
use
> a PF_PACKET socket to:
> - send a packet to specific NBMA address with sendto()
> - use recvfrom() to receive packet and check which NBMA address it ca=
me=20
> from
>=20
> Signed-off-by: Timo Teras <timo.teras@iki.fi>
>=20
> ---
>=20
> This is useful for implementing NHRP (and other low level protocols) =
over
> NBMA GRE tunnels.
>=20
> Posted about a week ago, but got no reply. Could someone comment on t=
his?
> Or commit it? Thanks.


Your mailer mangled tabs, it won't apply like this. Try sending to
yourself for testing, then repost when it works properly.
