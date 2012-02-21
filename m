From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rtnetlink: Fix problem with buffer allocation
Date: Tue, 21 Feb 2012 16:32:09 -0500 (EST)
Message-ID: <20120221.163209.2238982548619784853.davem@davemloft.net>
References: <20120221.161630.1122203779408129070.davem@davemloft.net>
	<20120221.162125.1533105883101299190.davem@davemloft.net>
	<C5551D9AAB213A418B7FD5E4A6F30A0702F95D79@ORSMSX106.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gregory.v.rose@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60839 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753033Ab2BUVcM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 16:32:12 -0500
In-Reply-To: <C5551D9AAB213A418B7FD5E4A6F30A0702F95D79@ORSMSX106.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Date: Tue, 21 Feb 2012 21:28:17 +0000

> I compile tested it on my development machine and then exported it
> to a machine that can connect to the internet and mail patches.  I
> must have screwed something up at that point.
> 
> Let me see what the heck I did.

It looks like a quarter of the patch got lost, because if you look at
the RFC,V3 version of your patch at:

http://patchwork.ozlabs.org/patch/141714/

all the necessary bits appear to be there.
