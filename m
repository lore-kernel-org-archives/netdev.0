From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] team: send only changed options/ports via netlink
Date: Tue, 24 Jan 2012 15:51:10 -0500 (EST)
Message-ID: <20120124.155110.209158202726135395.davem@davemloft.net>
References: <1327418160-8098-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41835 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757222Ab2AXUvM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2012 15:51:12 -0500
In-Reply-To: <1327418160-8098-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Tue, 24 Jan 2012 16:16:00 +0100

> This patch changes event message behavious to send only updated records
> instead of whole list. This fixes bug on which userspace receives non-actual
> data in case multiple events occur in row.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied, thanks.
