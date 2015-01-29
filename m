From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Don't increase PMTU with Datagram Too Big
 message.
Date: Thu, 29 Jan 2015 15:29:26 -0800 (PST)
Message-ID: <20150129.152926.959311618193916475.davem@davemloft.net>
References: <1422518943-30637-1-git-send-email-lw@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lw@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43140 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758808AbbA2X31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 18:29:27 -0500
In-Reply-To: <1422518943-30637-1-git-send-email-lw@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Wei <lw@cn.fujitsu.com>
Date: Thu, 29 Jan 2015 16:09:03 +0800

> RFC 1191 said, "a host MUST not increase its estimate of the Path
> MTU in response to the contents of a Datagram Too Big message."
> 
> Signed-off-by: Li Wei <lw@cn.fujitsu.com>

Applied, thank you.
