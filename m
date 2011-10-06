From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 3/3] dcb: Add stub routines for !CONFIG_DCB
Date: Thu, 06 Oct 2011 15:50:31 -0400 (EDT)
Message-ID: <20111006.155031.732191609652266208.davem@davemloft.net>
References: <20111006185233.2781.80310.stgit@jf-dev1-dcblab>
	<20111006185243.2781.67932.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59156 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759214Ab1JFTue (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 15:50:34 -0400
In-Reply-To: <20111006185243.2781.67932.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Thu, 06 Oct 2011 11:52:44 -0700

> To avoid ifdefs in the other code that supports DCB notifiers
> add stub routines. This method seems popular in other net code
> for example 8021Q.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied.
