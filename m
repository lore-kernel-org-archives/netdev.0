From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [LLC]: Kill static inline llc_addrany
Date: Fri, 29 Feb 2008 11:46:27 -0800 (PST)
Message-ID: <20080229.114627.215835257.davem@davemloft.net>
References: <1204301596-15568-1-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1204301596-15568-2-git-send-email-ilpo.jarvinen@helsinki.fi>
	<20080229162833.GO4306@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59386
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757678AbYB2Tq1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Feb 2008 14:46:27 -0500
In-Reply-To: <20080229162833.GO4306@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Fri, 29 Feb 2008 13:28:33 -0300

> Em Fri, Feb 29, 2008 at 06:13:16PM +0200, Ilpo J=E4rvinen escreveu:
> > After the patch:
> > $ git-grep llc_addrany | wc -l
> > 0
> >=20
> > Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
> > Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Also applied, thanks.
