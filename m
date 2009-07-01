From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: make bridge-nf-call-*tables default
 configurable
Date: Wed, 01 Jul 2009 09:08:49 -0700 (PDT)
Message-ID: <20090701.090849.31764824.davem@davemloft.net>
References: <4A4B3F9A.9060105@trash.net>
	<20090701.090250.52376308.davem@davemloft.net>
	<4A4B8954.70803@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: markmc@redhat.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59763
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751278AbZGAQIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 12:08:43 -0400
In-Reply-To: <4A4B8954.70803@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 01 Jul 2009 18:05:40 +0200

> David Miller wrote:
>> From: Patrick McHardy <kaber@trash.net>
>> Date: Wed, 01 Jul 2009 12:51:06 +0200
>> 
>>> I agree, this has already caused an endless amount of problems for
>>> users due to the unexpected behaviour and, in some cases, bugs.
>>>
>>> Dave's point is certainly valid as well, until we change the defaults,
>>> distributions can use sysctl.conf. But I think we should move towards
>>> changing the defaults.
>> You must do this via something like your suggestion, the
>> feature-removal-schedule.txt thing.
> 
> Yes, of course. But I prefer the runtime warning (at least on top),
> my feeling is not many people actually read feature-removal-schedule.

Ok.
