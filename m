From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/9] get rid of unused revision element
Date: Sat, 12 Jan 2008 20:50:59 -0800 (PST)
Message-ID: <20080112.205059.223738374.davem@davemloft.net>
References: <20080112064513.803976049@linux-foundation.org>
	<20080112064646.132747871@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robert.olsson@its.uu.se, netdev@vger.kernel.org,
	stephen.hemminger@vyatta.com
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48432
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753565AbYAMEvA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2008 23:51:00 -0500
In-Reply-To: <20080112064646.132747871@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 11 Jan 2008 22:45:15 -0800

> The revision element must of been part of an earlier design,
> because currently it is set but never used.
> 
> Signed-off-by: Stephen Hemminger <stephen.hemminger@vyatta.com>

Applied.

I suspect Robert wanted to play around with some generation
ID optimizations but never got around to it.
