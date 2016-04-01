From: Michael Ma <make0818@gmail.com>
Subject: Re: qdisc spin lock
Date: Fri, 1 Apr 2016 10:17:36 -0700
Message-ID: <CAAmHdhx9=p6+CZpa7j-XcO2VE4th0+tggS_10Kye22RnL8rPSA@mail.gmail.com>
References: <CAAmHdhw9bQkCm7uehRZ9mTetMzafdXxWhYj16f8W-YvSz8V4=g@mail.gmail.com>
	<CAM_iQpVSHqLcGjrErAsh54+iD8uwGH5QNGwiJVOQOTsk=dwDbw@mail.gmail.com>
	<CAAmHdhxagKnLP1_5ZW7HTsVBu0TSFYKCvNstAEWN-NHrdnvvVQ@mail.gmail.com>
	<20160331.221909.800235529624766700.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34657 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751775AbcDARRh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 13:17:37 -0400
Received: by mail-io0-f194.google.com with SMTP id z133so6452559iod.1
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 10:17:37 -0700 (PDT)
In-Reply-To: <20160331.221909.800235529624766700.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-03-31 19:19 GMT-07:00 David Miller <davem@davemloft.net>:
> From: Michael Ma <make0818@gmail.com>
> Date: Thu, 31 Mar 2016 16:48:43 -0700
>
>> I didn't really know that multiple qdiscs can be isolated using MQ so
>  ...
>
> Please stop top-posting.

Sorry that I wasn't aware of this...
