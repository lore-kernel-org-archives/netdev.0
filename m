From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v7 1/3] geneve: implement support for IPv6-based tunnels
Date: Fri, 30 Oct 2015 12:11:31 +0900 (KST)
Message-ID: <20151030.121131.1551415052461681112.davem@davemloft.net>
References: <1445611225-27095-1-git-send-email-linville@tuxdriver.com>
	<1445893306-31225-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com, jesse@nicira.com,
	jbenc@redhat.com, hideaki.yoshifuji@miraclelinux.com
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59794 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756820AbbJ3DLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 23:11:42 -0400
In-Reply-To: <1445893306-31225-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Mon, 26 Oct 2015 17:01:44 -0400

> NOTE: Link-local IPv6 addresses for remote endpoints are not supported,
> since the driver currently has no capacity for binding a geneve
> interface to a specific link.
> 
> Signed-off-by: John W. Linville <linville@tuxdriver.com>
> Reviewed-by: Jesse Gross <jesse@nicira.com>

Applied.
