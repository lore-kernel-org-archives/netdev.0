From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: cleanups to use IS_ENABLED(CONFIG_FOO)
Date: Tue, 06 Dec 2011 13:23:58 -0500 (EST)
Message-ID: <20111206.132358.487635887913670480.davem@davemloft.net>
References: <1323174289-2289-1-git-send-email-kinwin2008@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ronyjin@tencent.com
To: kinwin2008@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60285 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752521Ab1LFSYt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 13:24:49 -0500
In-Reply-To: <1323174289-2289-1-git-send-email-kinwin2008@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Feng King <kinwin2008@gmail.com>
Date: Tue,  6 Dec 2011 20:24:49 +0800

> From: Feng Jin <ronyjin@tencent.com>
> 
> use #if IS_ENABLED(CONFIG_FOO) defined in include/linux/kconfig.h
> instead of #if defined(CONFIG_FOO) || defined(CONFIG_FOO_MODULE).
> 
> Signed-off-by: Feng Jin <ronyjin@tencent.com>

This patch does not apply to net-next properly.
