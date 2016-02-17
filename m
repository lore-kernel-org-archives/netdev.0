From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v2 0/8] tc offload for cls_u32 on ixgbe
Date: Tue, 16 Feb 2016 21:23:45 -0800
Message-ID: <56C403E1.6020508@gmail.com>
References: <20160216055819.32452.84181.stgit@john-Precision-Tower-5810> <20160216.201712.155104214233989878.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: amir@vadai.me, jhs@mojatatu.com, netdev@vger.kernel.org,
	jiri@resnulli.us, jeffrey.t.kirsher@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:36203 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030AbcBQFYA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 00:24:00 -0500
Received: by mail-pf0-f171.google.com with SMTP id e127so4851504pfe.3
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 21:24:00 -0800 (PST)
In-Reply-To: <20160216.201712.155104214233989878.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-16 05:17 PM, David Miller wrote:
> From: John Fastabend <john.fastabend@gmail.com>
> Date: Mon, 15 Feb 2016 22:00:03 -0800
> 
>> This extends the setup_tc framework so it can support more than just
>> the mqprio offload and push other classifiers and qdiscs into the
>> hardware.
>  ...
> 
> Jiri gave some minor stylistic feedback, please address that and
> respin, and I'll apply this series.
> 
> Thanks John.
> 

Sounds great I sent v3 and carried Jiri's Acks forward on the patches
he did Ack and made the fixes on the ones with comments.

Thanks
.John
