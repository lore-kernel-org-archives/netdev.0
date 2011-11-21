From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dccp: fix error propagation in dccp_v4_connect
Date: Mon, 21 Nov 2011 16:45:34 -0500 (EST)
Message-ID: <20111121.164534.159651712655267711.davem@davemloft.net>
References: <1321852700-2966-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41448 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757015Ab1KUVpg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 16:45:36 -0500
In-Reply-To: <1321852700-2966-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Mon, 21 Nov 2011 13:18:20 +0800

> From: RongQing.Li <roy.qing.li@gmail.com>
> 
> The errcode is not updated when ip_route_newports() fails.
> 
> Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>

Applied, thank you.
