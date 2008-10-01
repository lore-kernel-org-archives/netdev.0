From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] ipv6: NULL pointer dereferrence in
 tcp_v6_send_ack
Date: Wed, 01 Oct 2008 06:38:19 -0700 (PDT)
Message-ID: <20081001.063819.119769216.davem@davemloft.net>
References: <20081001.020359.48616451.davem@davemloft.net>
	<1222852317-7177-1-git-send-email-den@openvz.org>
	<20081001133409.GH970@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: den@openvz.org, xemul@openvz.org, vgusev@openvz.org,
	netdev@vger.kernel.org
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37539
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750769AbYJANia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 09:38:30 -0400
In-Reply-To: <20081001133409.GH970@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 1 Oct 2008 10:34:09 -0300

> Em Wed, Oct 01, 2008 at 01:11:57PM +0400, Denis V. Lunev escreveu:
> > Signed-off-by: Denis V. Lunev <den@openvz.org>
> > ---
> >  net/ipv4/tcp_ipv4.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> Forgot to update the diffstat? :-) Nah, just nitpicking :-P

Now I don't feel so bad about not noticing this :)
