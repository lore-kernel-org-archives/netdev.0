From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: How to compile tcp fast open client app with kernel tfo client
 support ?
Date: Mon, 12 Nov 2012 17:13:43 -0800
Message-ID: <CAGK4HS8SMk8W+hdUxaQ8qL=YW4WijJAP64hgdo6sekqpzUEu2g@mail.gmail.com>
References: <CAK3+h2xmgy+RhUy=MZ5Cu8Zpz+gQmt3dXCX0tpLAWFCTeujBLA@mail.gmail.com>
	<CAGK4HS-U+Ov5x8z+1CRZdiAD9MhfBUfurKKBbt1EWGYFLN8TcA@mail.gmail.com>
	<CAK3+h2z5=n6BHGzPjfbrJS4MbVGQ2pdMQP54dOZ8M=8xigUd3Q@mail.gmail.com>
	<CAK6E8=fc=hYppk=4+tnNF9UPvQNFhw8YKo-ebG2y6FwXTft_EQ@mail.gmail.com>
	<CAK3+h2xAqjs8CvkcwXiFryyQhDnohsN7-0KfQVjpegZh_AD1eg@mail.gmail.com>
	<1352492823.19779.825.camel@edumazet-glaptop>
	<CAGK4HS_SpdECk_KCu98Z1X9W02G9j9u7QE9B6qHEnTXLeZbqgA@mail.gmail.com>
	<CAK3+h2y+Kctdfk6+q5UB56qemdEVY4Fw3AbqZwycL-uDWzD=Lg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Yuchung Cheng <ycheng@google.com>, netdev@vger.kernel.org
To: Vincent Li <vincent.mc.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:41801 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753710Ab2KMBNo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2012 20:13:44 -0500
Received: by mail-oa0-f46.google.com with SMTP id h16so6917311oag.19
        for <netdev@vger.kernel.org>; Mon, 12 Nov 2012 17:13:43 -0800 (PST)
In-Reply-To: <CAK3+h2y+Kctdfk6+q5UB56qemdEVY4Fw3AbqZwycL-uDWzD=Lg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hi Vijay,
>
> just FYI, I filed a bug report in ubuntu and it appears to be a kernel
> commit breaks the user space code that still using deprecated kernel
> knobs oom_adj.
>

Vincent,
Thanks for following up and finding the exact cause!!

Vijay
