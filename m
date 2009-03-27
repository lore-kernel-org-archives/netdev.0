From: David Miller <davem@davemloft.net>
Subject: Re: [patch 09/30] tokenring: convert drivers to net_device_ops
Date: Fri, 27 Mar 2009 00:50:48 -0700 (PDT)
Message-ID: <20090327.005048.179497482.davem@davemloft.net>
References: <20090327011114.169107105@linux-foundation.org>
	<20090327011255.602662418@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57609
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754764AbZC0HvA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 03:51:00 -0400
In-Reply-To: <20090327011255.602662418@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Thu, 26 Mar 2009 18:11:23 -0700

> Convert madge and proteon drivers which are really just subclasses
> of tms380.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
