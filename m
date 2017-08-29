From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net] sch_htb: fix crash on init failure
Date: Wed, 30 Aug 2017 02:11:37 +0300
Message-ID: <1cd84fde-0a5e-2ac4-9daf-6daf035c3840@cumulusnetworks.com>
References: <1504029487-7085-1-git-send-email-nikolay@cumulusnetworks.com>
 <20170829.160625.1623439754611810483.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, jiri@resnulli.us,
        roopa@cumulusnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f176.google.com ([209.85.128.176]:37118 "EHLO
        mail-wr0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751684AbdH2XLl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 19:11:41 -0400
Received: by mail-wr0-f176.google.com with SMTP id k9so1841652wre.4
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 16:11:41 -0700 (PDT)
In-Reply-To: <20170829.160625.1623439754611810483.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30.08.2017 02:06, David Miller wrote:
> 
> I expect that you will resubmit all of these similar fixes as a patch
> series after you have sorted everything out.
> 
> Correct?
> 

Yes, I will. There are a few more places that need fixing, I'll resubmit
them all as a set.
