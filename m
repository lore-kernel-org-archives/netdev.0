From: David Miller <davem@davemloft.net>
Subject: Re: CPU utilization increased in 2.6.27rc
Date: Tue, 12 Aug 2008 18:05:35 -0700 (PDT)
Message-ID: <20080812.180535.99302127.davem@davemloft.net>
References: <48A23137.2010107@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gallatin@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50667
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751880AbYHMBFd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 21:05:33 -0400
In-Reply-To: <48A23137.2010107@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Gallatin <gallatin@myri.com>
Date: Tue, 12 Aug 2008 20:56:23 -0400

> According to oprofile, the system is spending a lot of
> time in __qdisc_run() when sending on the 1GbE forcedeth
> interface:

What does the profile look like beforehand?
