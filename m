From: Kumar SANGHVI <kumar.sanghvi@stericsson.com>
Subject: Re: [PATCH 4/4] Phonet: restore flow control credits when sending
 fails
Date: Thu, 30 Sep 2010 14:01:53 +0530
Message-ID: <20100930083152.GA29582@bnru01.bnr.st.com>
References: <1285835105-20293-1-git-send-email-kumar.sanghvi@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gulshan KARMANI <gulshan.karmani@stericsson.com>,
	Linus WALLEIJ <linus.walleij@stericsson.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"remi.denis-courmont@nokia.com" <remi.denis-courmont@nokia.com>,
	"eric.dumazet@gmail.co
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:44221 "EHLO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752237Ab0I3IcH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 04:32:07 -0400
Content-Disposition: inline
In-Reply-To: <1285835105-20293-1-git-send-email-kumar.sanghvi@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

On Thu, Sep 30, 2010 at 10:25:05 +0200, Kumar A SANGHVI wrote:
> From: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
>=20
> This patch restores the below flow control patch submitted by R=E9mi
> Denis-Courmont, which accidentaly got lost due to Pipe controller pat=
ch
> on Phonet.
>=20
> 	commit 1a98214feef2221cd7c24b17cd688a5a9d85b2ea
> 	Author: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
> 	Date:   Mon Aug 30 12:57:03 2010 +0000
>=20
> 	Phonet: restore flow control credits when sending fails
>=20
> 	Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
> 	Signed-off-by: David S. Miller <davem@davemloft.net>
>=20
> Signed-off-by: Kumar Sanghvi <kumar.sanghvi@stericsson.com>
> Acked-by: Linus Walleij <linus.walleij@stericsson.com>

Please discard this.
I will send a new patch.

Thanks,
Kumar.=20
