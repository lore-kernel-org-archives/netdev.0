From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] niu: Fix races between up/down and get_stats.
Date: Fri, 11 Feb 2011 11:33:45 -0800 (PST)
Message-ID: <20110211.113345.260097421.davem@davemloft.net>
References: <20110203.162529.260086668.davem@davemloft.net>
	<20110204162646.GC3710@redhat.com>
	<20110211172952.GA3112@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fleitner@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57515
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757513Ab1BKTdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 14:33:09 -0500
In-Reply-To: <20110211172952.GA3112@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fleitner@redhat.com>
Date: Fri, 11 Feb 2011 15:29:52 -0200

> Got a feedback that your patch works out too.

Thanks a lot Flavio.
