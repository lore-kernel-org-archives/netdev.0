From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/2] man/send(2): add EPERM to the list of possible errors
Date: Wed, 27 Mar 2013 18:42:08 +0100
Message-ID: <20130327174207.GA5725@localhost>
References: <1363675513.4767.6.camel@nexus>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Kerrisk <mtk.manpages@gmail.com>,
	linux-man@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Hirotaka Sasaki <sasaki.hirotaka@lab.ntt.co.jp>
To: Fernando Luis =?iso-8859-1?Q?V=E1zquez?= Cao
	<fernando_b1@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33200 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754044Ab3C0RmN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Mar 2013 13:42:13 -0400
Content-Disposition: inline
In-Reply-To: <1363675513.4767.6.camel@nexus>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 19, 2013 at 03:45:13PM +0900, Fernando Luis V=E1zquez Cao w=
rote:
> Subject: [PATCH 1/2] man/send(2): add EPERM to the list of possible e=
rrors
>=20
> System policy (for example netfilter rule) can cause a send* operatio=
n
> to fail with EPERM.
>=20
> Reported-by: Hirotaka Sasaki <sasaki.hirotaka@lab.ntt.co.jp>
> Signed-off-by: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>

Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>
