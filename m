From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [SCTP]: Kill unused static inline
 sctp_sysctl_jiffies_ms
Date: Fri, 29 Feb 2008 11:45:45 -0800 (PST)
Message-ID: <20080229.114545.112949128.davem@davemloft.net>
References: <1204301596-15568-1-git-send-email-ilpo.jarvinen@helsinki.fi>
	<47C83C59.9000304@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59383
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754889AbYB2Tpp convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Feb 2008 14:45:45 -0500
In-Reply-To: <47C83C59.9000304@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Fri, 29 Feb 2008 12:09:45 -0500

> Ilpo J=E4rvinen wrote:
> > After the patch:
> > $ git-grep sctp_sysctl_jiffies_ms | wc -l
> > 0
> >=20
> > Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
> > Cc: Vlad Yasevich <vladislav.yasevich@hp.com>
>=20
> Good catch.  Looks like dead declaration.
>=20
> Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied to net-2.6.26, thanks everyone.
