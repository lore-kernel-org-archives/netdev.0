From: David Miller <davem@davemloft.net>
Subject: Re: [patch 04/13] ppp_generic: fix lockdep warning
Date: Fri, 11 May 2007 14:03:09 -0700 (PDT)
Message-ID: <20070511.140309.59656886.davem@davemloft.net>
References: <200705110552.l4B5qnwC007799@shell0.pdx.osdl.net>
	<4644D8AF.7060403@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org, jarkao2@o2.pl,
	jura@netams.com, paulus@samba.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45847
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030773AbXEKVDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 17:03:05 -0400
In-Reply-To: <4644D8AF.7060403@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Fri, 11 May 2007 16:57:19 -0400

> applied

I was under the impression that this patch didn't actually fix the
problem yet?  I might be thinking about something else...
