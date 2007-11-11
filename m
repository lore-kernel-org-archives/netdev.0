From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][PACKET] Use existing sock refcnt debugging
 infrastructure
Date: Sat, 10 Nov 2007 21:38:57 -0800 (PST)
Message-ID: <20071110.213857.224693587.davem@davemloft.net>
References: <4734631D.6080807@openvz.org>
	<20071109143742.GC12019@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org, devel@openvz.org
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48578
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751339AbXKKFi6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2007 00:38:58 -0500
In-Reply-To: <20071109143742.GC12019@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Arnaldo Carvalho de Melo" <acme@redhat.com>
Date: Fri, 9 Nov 2007 12:37:42 -0200

> Em Fri, Nov 09, 2007 at 04:39:41PM +0300, Pavel Emelyanov escreveu:
> > The packet_socks_nr variable is used purely for debugging
> > the number of sockets.
> > 
> > As Arnaldo pointed out, there's already an infrastructure
> > for this purposes, so switch to using it.
> > 
> > Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Applied.
