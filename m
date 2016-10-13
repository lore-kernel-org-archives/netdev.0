From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH iproute2 1/1] tc filters: add support to get individual
 filters by handle
Date: Thu, 13 Oct 2016 07:51:24 -0400
Message-ID: <f05cfeee-773c-b256-745c-ee479a8bcb10@mojatatu.com>
References: <1476117914-32207-1-git-send-email-jhs@emojatatu.com>
 <CAM_iQpVo-+jvJaBkJWR5ojkHKWY1fszDjPT+BYG20Vmb-dMtLQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Roman Mashak <mrv@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35343 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754038AbcJMLvx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 07:51:53 -0400
Received: by mail-it0-f65.google.com with SMTP id l13so5680652itl.2
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 04:51:26 -0700 (PDT)
In-Reply-To: <CAM_iQpVo-+jvJaBkJWR5ojkHKWY1fszDjPT+BYG20Vmb-dMtLQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-10-12 12:46 PM, Cong Wang wrote:
> On Mon, Oct 10, 2016 at 9:45 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>>  tc/tc_filter.c | 185 +++++++++++++++++++++++++++++++++++++++++++++++++++++----
>>  1 file changed, 175 insertions(+), 10 deletions(-)
>
> Please update man/man8/tc.8 too, but can be a separated patch. ;)
>

Excellent point.
Punted to Roman ;->

cheers,
jamal
