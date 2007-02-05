From: David Miller <davem@davemloft.net>
Subject: Re: [Patch][IPv6] Fix wrong routing mechanism for Link Local IPv6
 packets
Date: Sun, 04 Feb 2007 16:59:39 -0800 (PST)
Message-ID: <20070204.165939.133260811.davem@davemloft.net>
References: <20070131.140914.105443849.yoshfuji@linux-ipv6.org>
	<20070131.141408.22662891.yoshfuji@linux-ipv6.org>
	<20070131.144250.58478716.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-users@linux-ipv6.org,
	weid@np.css.fujitsu.com
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55721
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752629AbXBEA7k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Feb 2007 19:59:40 -0500
In-Reply-To: <20070131.144250.58478716.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Wed, 31 Jan 2007 14:42:50 +0900 (JST)

> [IPV6] ROUTE: Do not route packets to link-local address on other device.
> 
> With help from Wei Dong <weid@np.css.fujitsu.com>.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied, thank you.
