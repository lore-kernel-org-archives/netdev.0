From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] net: cls_u32: Add support for skip-sw
 flag to tc u32 classifier.
Date: Thu, 12 May 2016 00:15:46 -0400 (EDT)
Message-ID: <20160512.001546.1671453290307211390.davem@davemloft.net>
References: <1462821524-2534-2-git-send-email-sridhar.samudrala@intel.com>
	<20160511.192316.1290350535833930948.davem@davemloft.net>
	<5733C3F7.1060800@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org
To: sridhar.samudrala@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54073 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751327AbcELEPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 00:15:52 -0400
In-Reply-To: <5733C3F7.1060800@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Date: Wed, 11 May 2016 16:44:55 -0700

> 
> On 5/11/2016 4:23 PM, David Miller wrote:
>> This is a core semantic issue, and we have to make sure all amongst us
>> that we are all comfortable with exporting the offloadability controls
>> in the way you are implementing them.
> 
> I tried to implement the semantics based on an earlier discussion
> about these flags in this
> email thread.
>     http://thread.gmane.org/gmane.linux.network/401733

Most developers reading your patches will not know to go to that URL,
nor that we even had that discussion at all.
