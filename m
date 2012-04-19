From: David Miller <davem@davemloft.net>
Subject: Re: net-next iwlwifi breaks compile - was Re: pull request:
 wireless-next 2012-04-18
Date: Thu, 19 Apr 2012 16:27:44 -0400 (EDT)
Message-ID: <20120419.162744.2197721179697327138.davem@davemloft.net>
References: <4595B4D22AB93C4FABBA84AAD5AA37FD1258AA@ORSMSX103.amr.corp.intel.com>
	<20120419.154954.1322943404183128381.davem@davemloft.net>
	<1334866241.27767.156.camel@wwguy-huron>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: meenakshi.venkataraman@intel.com, socketcan@hartkopp.net,
	linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, david.spinadel@intel.com
To: wey-yi.w.guy@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52370 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751371Ab2DSUbD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 16:31:03 -0400
In-Reply-To: <1334866241.27767.156.camel@wwguy-huron>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Guy, Wey-Yi" <wey-yi.w.guy@intel.com>
Date: Thu, 19 Apr 2012 13:10:41 -0700

> On Thu, 2012-04-19 at 15:49 -0400, David Miller wrote:
>> From: "Venkataraman, Meenakshi" <meenakshi.venkataraman@intel.com>
>> Date: Thu, 19 Apr 2012 19:47:58 +0000
>> 
>> > It was fixed internally in a subsequent patch, but that patch has
>> > not made it into net-next. I don't see it in the public iwlwifi
>> > repository either. We'll add the fix to the repository so you can
>> > pick it up.
>> 
>> That's not how this works.
>> 
>> You should submit a patch to fix the build directly to me, immediately,
>> so that I can push it directly into net-next as fast as possible.
> 
> The patch "iwlwifi-Remove-inconsistent-and-redundant-declaratio.patch"
> already being push to John to address this issue

You don't understand, that's exactly what I'm telling you I want
to avoid.

Then we all have to wait until John takes it, then we have to wait until
John is able to do a push to me, then we have to wait until I see John's
request and pull it, and then we have to wait until I am done build
testing and push the result out.

All of this red tape adds unacceptble time just to fix the build
regression added to net-next.

PUSH THIS FIX DIRECTLY TO ME NOW so that the build regression can get
fixed NOW.
