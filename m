From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] make struct ipv6_devconf static
Date: Tue, 22 Jul 2008 14:22:08 -0700 (PDT)
Message-ID: <20080722.142208.239078142.davem@davemloft.net>
References: <20080722172102.GV14846@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: bunk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59927
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753173AbYGVVWI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 17:22:08 -0400
In-Reply-To: <20080722172102.GV14846@cs181140183.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Adrian Bunk <bunk@kernel.org>
Date: Tue, 22 Jul 2008 20:21:02 +0300

> struct ipv6_devconf can now become static.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

Applied, thanks Adrian.
