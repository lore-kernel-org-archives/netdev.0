From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net] ip[6]: don't register inet[6]dev when dev is down
Date: Mon, 10 Jul 2017 10:20:00 +0200
Message-ID: <e7f91fe1-ee1e-7edd-cfe7-fa0744576f27@6wind.com>
References: <20170705155725.15469-1-nicolas.dichtel@6wind.com>
 <CAM_iQpUtniWmKAOGnjJ+d-cWeQkgEPhcwKFdMeVy49rCe2Sh5g@mail.gmail.com>
 <7238f160-2547-c51a-c8fe-bcbc5d774239@6wind.com>
 <CAM_iQpXMR6RmJX52=7qrGVKopvGCiabS2sUOCf2Dvjhe4wLAzA@mail.gmail.com>
 <dc593730-11ff-5fee-b3c4-ce6ebeb2926f@6wind.com>
 <CAM_iQpXZ4XGsDR=ntURTj-j9kXAA=y8HQ2O6bCrTcOq=GBs-XQ@mail.gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Hongjun Li <hongjun.li@6wind.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f172.google.com ([209.85.128.172]:35868 "EHLO
        mail-wr0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752454AbdGJIUB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2017 04:20:01 -0400
Received: by mail-wr0-f172.google.com with SMTP id c11so127930191wrc.3
        for <netdev@vger.kernel.org>; Mon, 10 Jul 2017 01:20:00 -0700 (PDT)
In-Reply-To: <CAM_iQpXZ4XGsDR=ntURTj-j9kXAA=y8HQ2O6bCrTcOq=GBs-XQ@mail.gmail.com>
Content-Language: fr
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 08/07/2017 à 20:56, Cong Wang a écrit :
> On Fri, Jul 7, 2017 at 5:39 AM, Nicolas Dichtel
> <nicolas.dichtel@6wind.com> wrote:
[snip]
>>  - the patch is easy to backport in older kernel.
>>
> 
> Easy to backport doesn't mean easy to verify. ;) As David said, this
> code is mess, especially for the keep_addr_on_down logic.
> 
Yes sure. Let's live with your patch.


Thank you,
Nicolas
