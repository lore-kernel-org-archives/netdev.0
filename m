From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/6 v2] net/ucc_geth: Assign six threads to Rx for UEC
Date: Fri, 01 May 2009 15:03:07 -0700 (PDT)
Message-ID: <20090501.150307.195064038.davem@davemloft.net>
References: <1241206851-27749-2-git-send-email-Haiying.Wang@freescale.com>
	<1241206851-27749-3-git-send-email-Haiying.Wang@freescale.com>
	<F2CB7830-33F9-4F6C-A782-6B086166FC4D@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, Haiying.Wang@freescale.com,
	netdev@vger.kernel.org
To: galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33557
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751913AbZEAWDN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 18:03:13 -0400
In-Reply-To: <F2CB7830-33F9-4F6C-A782-6B086166FC4D@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Gala <galak@kernel.crashing.org>
Date: Fri, 1 May 2009 16:56:19 -0500

> 
> On May 1, 2009, at 2:40 PM, Haiying Wang wrote:
> 
>> in the case the QE has 46 SNUMs for the threads to support four UCC
>> Ethernet at
>> 1000Base-T simultaneously.
>>
>> Signed-off-by: Haiying Wang <Haiying.Wang@freescale.com>
>> ---
>> v2 change: Add comments for the Rx threads change.
>> drivers/net/ucc_geth.c |   10 +++++++++-
>> 1 files changed, 9 insertions(+), 1 deletions(-)
> 
> Dave,
> 
> One more patch for you to Ack and let me handle via the powerpc tree
> because of dependencies.

Acked-by: David S. Miller <davem@davemloft.net>
