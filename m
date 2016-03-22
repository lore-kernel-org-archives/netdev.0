From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: Fix indentation of the conf/ documentation
 block
Date: Mon, 21 Mar 2016 22:58:46 -0400 (EDT)
Message-ID: <20160321.225846.385242348467843562.davem@davemloft.net>
References: <1458591700-5547-1-git-send-email-bpoirier@suse.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, corbet@lwn.net, jeder@redhat.com
To: bpoirier@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57214 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751074AbcCVC6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2016 22:58:48 -0400
In-Reply-To: <1458591700-5547-1-git-send-email-bpoirier@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Poirier <bpoirier@suse.com>
Date: Mon, 21 Mar 2016 13:21:39 -0700

> Commit d67ef35fff67 ("clarify documentation for
> net.ipv4.igmp_max_memberships") mistakenly indented a block of
> documentation such that it now looks like it belongs to a specific sysctl.
> Restore that block's original position.
> 
> Cc: Jeremy Eder <jeder@redhat.com>
> Signed-off-by: Benjamin Poirier <bpoirier@suse.com>

Applied.
