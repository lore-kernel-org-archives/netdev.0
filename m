From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net PATCH 1/1] net sched actions: policer missing timestamp
 processing
Date: Mon, 23 May 2016 20:56:17 -0400
Message-ID: <5743A6B1.3070702@mojatatu.com>
References: <1463935423-8918-1-git-send-email-jhs@emojatatu.com>
 <CAM_iQpWhRRqJWNaRXbFSPEVu+CTSb++z8A5Y3SB-vjmk1-gXmw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:35822 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892AbcEXA4U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2016 20:56:20 -0400
Received: by mail-ig0-f171.google.com with SMTP id bi2so43757041igb.0
        for <netdev@vger.kernel.org>; Mon, 23 May 2016 17:56:20 -0700 (PDT)
In-Reply-To: <CAM_iQpWhRRqJWNaRXbFSPEVu+CTSb++z8A5Y3SB-vjmk1-gXmw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-05-23 04:52 PM, Cong Wang wrote:

>> +       tcf_tm_dump(&t, &police->tcf_tm);
>
> This depends on a previous patch you sent, right?
>

Sigh. There goes my git foo.
Will resubmit an updated version.


cheers,
jamal
