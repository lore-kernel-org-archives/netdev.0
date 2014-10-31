From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] mpls: Fix mpls_gso handler.
Date: Fri, 31 Oct 2014 15:47:52 -0400 (EDT)
Message-ID: <20141031.154752.880623963009752289.davem@davemloft.net>
References: <1414655397-1541-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, simon.horman@netronome.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42960 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755603AbaJaTr6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2014 15:47:58 -0400
In-Reply-To: <1414655397-1541-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Thu, 30 Oct 2014 00:49:57 -0700

> mpls gso handler needs to pull skb after segmenting skb.
> 
> CC: Simon Horman <simon.horman@netronome.com>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Applied.
