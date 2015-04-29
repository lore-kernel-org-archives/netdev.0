From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] bnx2x: minor cleanups related to TPA bits
Date: Wed, 29 Apr 2015 14:47:33 -0400 (EDT)
Message-ID: <20150429.144733.1800376779476877473.davem@davemloft.net>
References: <1430213663-5657-1-git-send-email-mschmidt@redhat.com>
	<B5657A6538887040AD3A81F1008BEC63D2406E@AVMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mschmidt@redhat.com, netdev@vger.kernel.org,
	Ariel.Elior@qlogic.com, Dmitry.Kravkov@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50088 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213AbbD2Srf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 14:47:35 -0400
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63D2406E@AVMB1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Tue, 28 Apr 2015 10:45:17 +0000

>> I noticed some simplification possibilities while looking into the bug fixed by
>> "bnx2x: really disable TPA if 'disable_tpa' is set'.
>> 
>> Michal Schmidt (3):
>>   bnx2x: mark LRO as a fixed disabled feature if disable_tpa is set
>>   bnx2x: merge fp->disable_tpa with fp->mode
>>   bnx2x: remove {TPA,GRO}_ENABLE_FLAG
>> 
> 
> Looking good; Thanks Michal.
> 
> Acked-by: Yuval Mintz <Yuval.Mintz@qlogic.com>

Aha, I missed this initially, ignore my previous email and I'll apply this
series, thanks.
