From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next 0/3] bnx2x: Message logging cleanups
Date: Wed, 17 Aug 2011 15:47:37 -0700 (PDT)
Message-ID: <20110817.154737.1005956281645867066.davem@davemloft.net>
References: <cover.1313360100.git.joe@perches.com>
	<1313588528.7266.6.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53581 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754315Ab1HQWro (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2011 18:47:44 -0400
In-Reply-To: <1313588528.7266.6.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Wed, 17 Aug 2011 16:42:08 +0300

> On Sun, 2011-08-14 at 15:16 -0700, Joe Perches wrote: 
>> Joe Perches (3):
>>   bnx2x: Remove local defines for %pM and mac address
>>   bnx2x: Coalesce pr_cont uses and fix DP typos
>>   bnx2x: Use pr_fmt and message logging cleanups
>> 
>>  drivers/net/ethernet/broadcom/bnx2x/bnx2x.h        |   67 ++++-----
>>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |   48 ++++---
>>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |    4 +-
>>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c    |    5 +-
>>  .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |   23 ++--
>>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c   |  153 ++++++++++----------
>>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |   72 ++++-----
>>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c     |   67 ++++-----
>>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c  |   46 +++---
>>  9 files changed, 244 insertions(+), 241 deletions(-)
>> 
> 
> Thanks Joe, sorry it took a while - but ACK for all :)

All applied, thanks everyone.
