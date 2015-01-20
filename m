From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: ipv6: Add sysctl entry to disable MTU
 updates from RA
Date: Mon, 19 Jan 2015 19:29:55 -0500 (EST)
Message-ID: <20150119.192955.1350068974986296916.davem@davemloft.net>
References: <1421703363-3376-1-git-send-email-harouth@codeaurora.org>
	<54BD80D6.40402@redhat.com>
	<001501d03439$28f6d670$7ae48350$@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org
To: harouth@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36786 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751734AbbATA37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 19:29:59 -0500
In-Reply-To: <001501d03439$28f6d670$7ae48350$@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Harout Hedeshian" <harouth@codeaurora.org>
Date: Mon, 19 Jan 2015 15:42:08 -0700

> Indeed, the patch is based on previous modifications to add sysctl/proc
> entries for IPv6 parameters. It is done this way to maintain consistency. Do
> you think we need a v3 without the changes to the sysctl_binary.c and
> corresponding changes in includes/uapi?

Probably, yes.
