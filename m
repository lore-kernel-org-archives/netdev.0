From: Li Yu <raise.sail@gmail.com>
Subject: Re: [PATCH 1/3] skbtrace v2: core feature and common events
Date: Sun, 28 Oct 2012 21:45:54 +0800
Message-ID: <CA+WLrf88zLtnO+U4akVjJTs1-C7Ndi_-U+7bxfZt1DSEr4si6g@mail.gmail.com>
References: <5080F031.5040804@gmail.com>
	<k5qvji$v6v$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:50712 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752233Ab2J1Np4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Oct 2012 09:45:56 -0400
Received: by mail-la0-f46.google.com with SMTP id h6so3229702lag.19
        for <netdev@vger.kernel.org>; Sun, 28 Oct 2012 06:45:54 -0700 (PDT)
In-Reply-To: <k5qvji$v6v$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/10/19 Cong Wang <xiyou.wangcong@gmail.com>:
> On Fri, 19 Oct 2012 at 06:16 GMT, Li Yu <raise.sail@gmail.com> wrote:
>> From: Li Yu <bingtian.ly@taobao.com>
>>
>> This patch contains:
>>
>> 1. The glue code of tracepoints subsystem and relay file system.
>> 2. API for particular networking trace points.
>> 3. The skb_rps_info trace point.
>>
>
>
> Any reason why not split it into three patches?
>

The first two parts are tight coupled, I will split part 3 into
another patch at next time.

Thanks.

Yu
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
