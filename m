From: "Arnaldo Carvalho de Melo" <acme@redhat.com>
Subject: Re: [PATCH][IPX] Use existing sock refcnt debugging infrastructure
Date: Fri, 9 Nov 2007 12:39:08 -0200
Message-ID: <20071109143908.GD12019@ghostprotocols.net>
References: <473463AD.9000807@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:50668 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759664AbXKIOjQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Nov 2007 09:39:16 -0500
Content-Disposition: inline
In-Reply-To: <473463AD.9000807@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Fri, Nov 09, 2007 at 04:42:05PM +0300, Pavel Emelyanov escreveu:
> Just like in the af_packet.c, the ipx_sock_nr variable is used
> for debugging purposes.
> 
> Switch to using existing infrastructure. Thanks to Arnaldo for
> pointing this out.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
