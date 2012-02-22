From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] netfilter: ip6_route_output() never returns NULL.
Date: Wed, 22 Feb 2012 14:50:21 -0500 (EST)
Message-ID: <20120222.145021.1169971493497466452.davem@davemloft.net>
References: <1329898251-5357-1-git-send-email-roy.qing.li@gmail.com>
	<1329898251-5357-3-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44566 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755951Ab2BVTuZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2012 14:50:25 -0500
In-Reply-To: <1329898251-5357-3-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Wed, 22 Feb 2012 16:10:51 +0800

> From: RongQing.Li <roy.qing.li@gmail.com>
> 
> ip6_route_output() never returns NULL, so it is wrong to
> check if the return value is NULL.
> 
> Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>

Applied.
