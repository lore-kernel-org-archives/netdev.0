From: David Miller <davem@davemloft.net>
Subject: Re: locking api self-test hanging
Date: Wed, 05 Mar 2008 00:27:14 -0800 (PST)
Message-ID: <20080305.002714.158217312.davem@davemloft.net>
References: <20080304075137.6bbd285f@extreme>
	<20080304.123000.183265831.davem@davemloft.net>
	<20080305002338.c7777808.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	rjw@sisk.pl
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38725
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752362AbYCEI1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 03:27:17 -0500
In-Reply-To: <20080305002338.c7777808.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 5 Mar 2008 00:23:38 -0800

> On Tue, 04 Mar 2008 12:30:00 -0800 (PST) David Miller <davem@davemloft.net> wrote:
> 
> >     [NETPOLL]: Revert two bogus cleanups that broke netconsole.
> 
> Seems OK now, thanks.

Great, thanks for testing.
