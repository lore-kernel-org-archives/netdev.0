From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/26] tipc: Yet another mixed bag of updates
Date: Sun, 13 Mar 2011 18:53:10 -0700 (PDT)
Message-ID: <20110313.185310.71123007.davem@davemloft.net>
References: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51179
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755818Ab1CNBwd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2011 21:52:33 -0400
In-Reply-To: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Sun, 13 Mar 2011 17:33:48 -0400

> Content varies, from cleanups to bugfixes to removals of orphaned code.
> 
> In the new functionality department, there is the SO_RCVTIMEO sockopt
> and the multi-chunk iovec changes that simply were not supported before.
> 
> In the removal dep't there were a couple more blocks relating to the
> now-gone prototype routing that can also now be deleted.
> 
> Nobody likes Kconfig options for micro tuning anymore, so one of those
> gets shot in the head, which triggered a bunch of associated cleanups,
> like the killing off of a largely useless global structure.
> 
> The remainder are either bugfixes or cosmetic cleanups initiated by
> the bugfix; with the usual intent of not mixing both types of content
> within a single commit, so that review/inspection is hopefully easier.

Looks good, pulled, thanks a lot!
