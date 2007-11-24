From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 02/22] NET: DM9000 update debugging macros to use debug
 level
Date: Fri, 23 Nov 2007 20:36:15 -0500
Message-ID: <4747800F.9060209@garzik.org>
References: <20071119203910.687238131@fluff.org> <20071119204013.065970173@fluff.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vince@simtec.co.uk
To: Ben Dooks <ben-linux@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36653 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752555AbXKXBgR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2007 20:36:17 -0500
In-Reply-To: <20071119204013.065970173@fluff.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

you really should consider adding msg_enable support (grep for that in 
other net drivers, and for netif_msg in netdevice.h)


