From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 15/17] fm10k: fix possible null pointer deref after
 kcalloc
Date: Thu, 21 Apr 2016 15:47:27 -0400 (EDT)
Message-ID: <20160421.154727.1143899173479860095.davem@davemloft.net>
References: <1461218969-68578-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1461218969-68578-16-git-send-email-jeffrey.t.kirsher@intel.com>
	<02874ECE860811409154E81DA85FBB5857A7C1E0@ORSMSX115.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: jacob.e.keller@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54898 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753476AbcDUTra (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 15:47:30 -0400
In-Reply-To: <02874ECE860811409154E81DA85FBB5857A7C1E0@ORSMSX115.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Date: Thu, 21 Apr 2016 19:44:24 +0000

> Dave, please don't pull this patch. Krishneil found an issue with
> this patch, and I sent a corrected fix to squash in but it didn't
> make it into this one. I'd like to get the fix squashed in a resend
> before this is pulled into net-next.

Too late, it's already in my tree.
