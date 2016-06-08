From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] cls_u32 hardware offload fixes
Date: Wed, 08 Jun 2016 11:09:36 -0700 (PDT)
Message-ID: <20160608.110936.851389252396914415.davem@davemloft.net>
References: <1465226208-32097-1-git-send-email-jakub.kicinski@netronome.com>
	<20160607.162731.1154473267162142674.davem@davemloft.net>
	<20160608111830.6ca8db51@jkicinski-Precision-T1700>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.r.fastabend@intel.com,
	sridhar.samudrala@intel.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38168 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751240AbcFHSJj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 14:09:39 -0400
In-Reply-To: <20160608111830.6ca8db51@jkicinski-Precision-T1700>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Wed, 8 Jun 2016 11:18:30 +0100

> On Tue, 07 Jun 2016 16:27:31 -0700 (PDT), David Miller wrote:
>> From: Jakub Kicinski <jakub.kicinski@netronome.com>
>> Date: Mon,  6 Jun 2016 16:16:46 +0100
>> 
>> > This set fixes two small issues with error codes I noticed
>> > in cls_u32.  Second patch could be viewed as user space API
>> > change but that portion of API is not part of any release,
>> > yet.
>> > 
>> > Compile tested only.  
>> 
>> Applied, thanks.
> 
> I think you applied v1 instead of v3 (which is still in patchwork) :S
> Should I post an incremental patch to bring the code to v3 state?

Yeah please do, sorry about that :-/
