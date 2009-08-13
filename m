From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] net: skb ftracer - Add actual ftrace code to
 kernel (v3)
Date: Thu, 13 Aug 2009 16:28:28 -0700 (PDT)
Message-ID: <20090813.162828.79537461.davem@davemloft.net>
References: <20090807202130.GA26677@hmsreliant.think-freely.org>
	<20090813145917.GA16521@hmsreliant.think-freely.org>
	<20090813152356.GC16682@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rostedt@goodmis.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56576
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756483AbZHMX2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 19:28:17 -0400
In-Reply-To: <20090813152356.GC16682@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Thu, 13 Aug 2009 11:23:56 -0400

> skb allocation / consumption correlator
> 
> Add ftracer module to kernel to print out a list that correlates a process id,
> an skb it read, and the numa nodes on wich the process was running when it was
> read along with the numa node the skbuff was allocated on.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied to net-next-2.6
