From: David Miller <davem@davemloft.net>
Subject: Re: [RFC V3 PATCH] rtnetlink: Fix problem with buffer allocation
Date: Tue, 21 Feb 2012 14:49:26 -0500 (EST)
Message-ID: <20120221.144926.1106286806287642272.davem@davemloft.net>
References: <20120220.005451.548532173290909435.davem@davemloft.net>
	<C5551D9AAB213A418B7FD5E4A6F30A0702F950C8@ORSMSX106.amr.corp.intel.com>
	<C5551D9AAB213A418B7FD5E4A6F30A0702F9537C@ORSMSX106.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gregory.v.rose@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59877 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752148Ab2BUTt3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 14:49:29 -0500
In-Reply-To: <C5551D9AAB213A418B7FD5E4A6F30A0702F9537C@ORSMSX106.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Date: Tue, 21 Feb 2012 17:46:27 +0000

> Having seen no other review comments on this RFC or the related
> iproute2 RFC I'll go ahead and work with Jeff Kirsher to get these
> patches pushed for application.

What do you mean by this?  Simply repost this patch with the fix I
asked for, and do it ASAP.

These are not Intel device driver specific changes, there is absolutely
no need to get Jeff involved at all.  It can only make things take more
time and add more red tape to the process of getting this urgent fix
propagated.

I've been extremely patient allowing you to take more than a week or
two to code up this fix for something which causes very serious
regressions for users, don't add any new things that will consume even
more time.
