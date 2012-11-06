From: Shan Wei <shanwei88@gmail.com>
Subject: Re: [PATCH] net: ipv6: change %8s to %s for seq_printf of if6_seq_stop
Date: Tue, 06 Nov 2012 09:42:14 +0800
Message-ID: <50986AF6.10904@gmail.com>
References: <5097A030.5030209@asianux.com> <509863D8.9020501@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev <netdev@vger.kernel.org>
To: Chen Gang <gang.chen@asianux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:34858 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754895Ab2KFBm3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2012 20:42:29 -0500
Received: by mail-pb0-f46.google.com with SMTP id rr4so3267pbb.19
        for <netdev@vger.kernel.org>; Mon, 05 Nov 2012 17:42:28 -0800 (PST)
In-Reply-To: <509863D8.9020501@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chen Gang said, at 2012/11/6 9:11:
> 1) sorry, the comments is incorrect
>    need use ifp->idev->dev->name instead of rt->dst.dev->name in 2nd line.
>    I will send it again.

New patch, you should tag new version in [PATCH]  to distinguish them.
i.e. [PATCH V4]

> 
> 2) By the way, the three patches "* %8s to %s *" are almost the same
>    If need merge them into one patch, please tell me, I shall do.

trivial patches, send them in one patch for net/ subsystem.

> 
>    thanks.
> 
