From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][NET_SCHED] sch_sfq: use del_timer_sync() in
 sfq_destroy()
Date: Tue, 29 Apr 2008 03:29:11 -0700 (PDT)
Message-ID: <20080429.032911.50520722.davem@davemloft.net>
References: <20080427125921.GA7480@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42740
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753439AbYD2K3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 06:29:12 -0400
In-Reply-To: <20080427125921.GA7480@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sun, 27 Apr 2008 14:59:21 +0200

> [NET_SCHED] sch_sfq: use del_timer_sync() in sfq_destroy()
> 
> Let's delete timer reliably in sfq_destroy().
> 
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied, thanks.
