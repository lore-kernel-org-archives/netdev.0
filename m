From: Naresh Kumar Inna <naresh@chelsio.com>
Subject: Re: [V3 PATCH 9/9] cxgb4vf: Chelsio FCoE offload driver submission
 (header compatibility fixes).
Date: Wed, 12 Sep 2012 22:50:25 +0530
Message-ID: <5050C459.3090402@chelsio.com>
References: <1347374347-3852-10-git-send-email-naresh@chelsio.com> <20120911.133321.282568248903907762.davem@davemloft.net> <50501F1A.6040905@chelsio.com> <20120912.014746.636228439025755624.davem@davemloft.net> <50502B3A.6080803@chelsio.com> <m2har3yyig.fsf@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"JBottomley@parallels.com" <JBottomley@parallels.com>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	Dimitrios Michailidis <dm@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Chethan Seshadri <chethan@chelsio.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:5637 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760676Ab2ILRVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2012 13:21:06 -0400
In-Reply-To: <m2har3yyig.fsf@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/12/2012 10:22 PM, Andi Kleen wrote:
> Naresh Kumar Inna <naresh@chelsio.com> writes:
>>
>> OK, I think I should be able to arrange the patch set to fulfill that
>> requirement. I was under the impression it was fine for new drivers to
>> split patches in this fashion, since they go as a single commit, sorry
>> about that.
> 
> What they normally do then is to add the Kconfig or Makefile entry
> only in the end, so it cannot build before.
> 
> -Andi
> 

Patch-set V4 I sent a few hours ago does just that. Thanks nevertheless.

-Naresh
