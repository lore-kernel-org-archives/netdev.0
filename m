From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/6] net/ucc_geth: update riscTx and riscRx in ucc_geth
Date: Wed, 29 Apr 2009 14:51:45 -0700 (PDT)
Message-ID: <20090429.145145.49692653.davem@davemloft.net>
References: <12410288792524-git-send-email-Haiying.Wang@freescale.com>
	<12410288811793-git-send-email-Haiying.Wang@freescale.com>
	<F640C411-797C-4A4D-BD1B-9A20114C57C3@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, Haiying.Wang@freescale.com,
	netdev@vger.kernel.org
To: galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59681
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752072AbZD2Vvv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 17:51:51 -0400
In-Reply-To: <F640C411-797C-4A4D-BD1B-9A20114C57C3@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Gala <galak@kernel.crashing.org>
Date: Wed, 29 Apr 2009 15:23:21 -0500

> 
> On Apr 29, 2009, at 1:14 PM, Haiying Wang wrote:
> 
>> Change the definition of riscTx and riscRx to unsigned integer instead
>> of enum,
>> and change their values to support 4 risc allocation if the qe has 4
>> RISC
>> engines.
>>
>> Signed-off-by: Haiying Wang <Haiying.Wang@freescale.com>
>> ---
> 
> Dave, if you can ack this it is probably easier if this goes via the
> powerpc tree as it had some dependancies.

Fair enough:

Acked-by: David S. Miller <davem@davemloft.net>
