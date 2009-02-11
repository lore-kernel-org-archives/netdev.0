From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Removing the unused PAGE_USE_COUNT() macro on
 ixgbe driver
Date: Tue, 10 Feb 2009 17:25:00 -0800 (PST)
Message-ID: <20090210.172500.254793935.davem@davemloft.net>
References: <4991C46D.3030705@linux.vnet.ibm.com>
	<Pine.WNT.4.64.0902101720340.18672@ppwaskie-MOBL2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: leitao@linux.vnet.ibm.com, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net, fubar@us.ibm.com
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44615
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753337AbZBKBZG convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Feb 2009 20:25:06 -0500
In-Reply-To: <Pine.WNT.4.64.0902101720340.18672@ppwaskie-MOBL2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Date: Tue, 10 Feb 2009 17:21:12 -0800 (Pacific Standard Time)

> On Tue, 10 Feb 2009, Breno Leitao wrote:
>=20
> > Removing the unused PAGE_USE_COUNT() macro. Also removing the unuse=
d pages=20
> > variable at ixgbe_configure_rx() function.
> >=20
> > Signed-off-by: Breno Leit=E3o <leitao@linux.vnet.ibm.com>
> > Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
>=20
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

Applied, thanks everyone.
