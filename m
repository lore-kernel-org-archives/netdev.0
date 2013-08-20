From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 3/3] macvtap: Ignore tap features when VNET_HDR is
 off
Date: Tue, 20 Aug 2013 13:09:47 -0700 (PDT)
Message-ID: <20130820.130947.286915112839184726.davem@davemloft.net>
References: <1376681102-19753-1-git-send-email-vyasevic@redhat.com>
	<1376681102-19753-4-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46454 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751789Ab3HTUJs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 16:09:48 -0400
In-Reply-To: <1376681102-19753-4-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Fri, 16 Aug 2013 15:25:02 -0400

> When the user turns off VNET_HDR support on the
> macvtap device, there is no way to provide any
> offload information to the user.  So, it's safer
> to ignore offload setting then depend on the user
> setting them correctly.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

Applied.
