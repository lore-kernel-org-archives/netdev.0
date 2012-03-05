From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] bridge: Adjust min age inc for HZ > 256
Date: Sun, 04 Mar 2012 21:57:48 -0500 (EST)
Message-ID: <20120304.215748.2233571009168131013.davem@davemloft.net>
References: <1330625539-10247-1-git-send-email-Joakim.Tjernlund@transmode.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joakim.Tjernlund@transmode.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47932 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755118Ab2CEC5x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2012 21:57:53 -0500
In-Reply-To: <1330625539-10247-1-git-send-email-Joakim.Tjernlund@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Date: Thu, 1 Mar 2012 19:12:18 +0100

> min age increment needs to round up its min age tick for all
> HZ values to guarantee message age is increasing.
> 
> Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>

Applied.
