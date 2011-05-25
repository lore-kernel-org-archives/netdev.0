From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: prevent deadlock on slave store with alb mode
 (v2)
Date: Wed, 25 May 2011 17:58:13 -0400 (EDT)
Message-ID: <20110525.175813.1624207728995221207.davem@davemloft.net>
References: <1306265765-8257-1-git-send-email-nhorman@tuxdriver.com>
	<1306343805-3223-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	nicolas.2p.debian@gmail.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34266 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932407Ab1EYV7j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2011 17:59:39 -0400
In-Reply-To: <1306343805-3223-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Wed, 25 May 2011 13:16:45 -0400

> This soft lockup was recently reported:
 ...
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> Reported-by: jtluka@redhat.com

Applied.
