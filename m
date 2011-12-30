From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] tipc: add tipc_ prefix to various structs
Date: Fri, 30 Dec 2011 13:53:27 -0500 (EST)
Message-ID: <20111230.135327.1216689291125377123.davem@davemloft.net>
References: <1325216937-5856-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43552 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751550Ab1L3Sxb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2011 13:53:31 -0500
In-Reply-To: <1325216937-5856-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Thu, 29 Dec 2011 22:48:49 -0500

> Here is the addition of the tipc_ prefix that you requested earlier
> this week.  I left the changes as separate commits since it makes it
> easier at a glance to review them and make sure my regex foo did
> the right thing in each case.  The last commit intentionally adds
> an "s" [i.e. name --> names] since that better describes what the
> struct actually contains.
> 
> I didn't redo runtime testing, but it is compile tested as a sanity
> check.  Long lines caused by the addition of the prefix have been
> wrapped so the patches are (as usual) checkpatch clean.

Pulled, thanks a lot.

> Happy New Year!

Same to you!
