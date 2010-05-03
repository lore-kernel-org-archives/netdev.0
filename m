From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH v2] sctp: fix sctp to work with ipv6 source address
 routing
Date: Mon, 03 May 2010 15:56:22 -0700 (PDT)
Message-ID: <20100503.155622.46319916.davem@davemloft.net>
References: <4BDEFFEF.2090200@hp.com>
	<1272906432-6237-1-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Weixing.Shi@windriver.com, yjwei@cn.fujitsu.com,
	netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46783
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756121Ab0ECW4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 18:56:16 -0400
In-Reply-To: <1272906432-6237-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Mon,  3 May 2010 13:07:12 -0400

> From: Weixing Shi <Weixing.Shi@windriver.com>
> 
> <vlad>
> Ok, updated to be a bit more correct.  Only leave the function early if the
> first lookup succeeds.
> </vlad>

This patch looks fine to me.
