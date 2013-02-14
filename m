From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] bridge: use __u16 in if_bridge.h
Date: Thu, 14 Feb 2013 00:54:34 -0500 (EST)
Message-ID: <20130214.005434.436773758080555565.davem@davemloft.net>
References: <1360819951-19484-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevic@redhat.com,
	stephen@networkplumber.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49684 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750990Ab3BNFyh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 00:54:37 -0500
In-Reply-To: <1360819951-19484-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Thu, 14 Feb 2013 13:32:31 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> We should use "__u16" instead of "u16" in the user-space visable
> header.
> 
> Cc: Vlad Yasevich <vyasevic@redhat.com>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Seems obvious enough, applied, thanks.
