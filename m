From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][IPX] Use existing sock refcnt debugging infrastructure
Date: Sat, 10 Nov 2007 21:39:40 -0800 (PST)
Message-ID: <20071110.213940.05628721.davem@davemloft.net>
References: <473463AD.9000807@openvz.org>
	<20071109143908.GD12019@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org, devel@openvz.org
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48585
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751748AbXKKFjl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2007 00:39:41 -0500
In-Reply-To: <20071109143908.GD12019@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Arnaldo Carvalho de Melo" <acme@redhat.com>
Date: Fri, 9 Nov 2007 12:39:08 -0200

> Em Fri, Nov 09, 2007 at 04:42:05PM +0300, Pavel Emelyanov escreveu:
> > Just like in the af_packet.c, the ipx_sock_nr variable is used
> > for debugging purposes.
> > 
> > Switch to using existing infrastructure. Thanks to Arnaldo for
> > pointing this out.
> > 
> > Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Also applied, thanks!
