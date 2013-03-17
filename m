From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: Add support for setting BR_ROOT_BLOCK flag.
Date: Sun, 17 Mar 2013 12:42:01 -0400 (EDT)
Message-ID: <20130317.124201.408283946540583285.davem@davemloft.net>
References: <1363365552-27451-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46197 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932541Ab3CQQmC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Mar 2013 12:42:02 -0400
In-Reply-To: <1363365552-27451-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Fri, 15 Mar 2013 12:39:12 -0400

> Most of the support was already there.  The only thing that was missing
> was the call to set the flag.  Add this call.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

This looks like an unintentional omission, so I've applied this
to 'net', thanks!
