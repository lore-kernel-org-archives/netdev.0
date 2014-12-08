From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH][net-next] net: avoid to call skb_queue_len again
Date: Mon, 08 Dec 2014 07:10:36 -0800
Message-ID: <1418051436.15618.43.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1417772948-17909-1-git-send-email-roy.qing.li@gmail.com>
	 <5481BBF2.40806@cogentembedded.com>
	 <1417789870.15618.1.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAJFZqHzeESfMBqb1gQr4DsE-v_fSfUX+AyWbt_VriJJ8Dj2FnA@mail.gmail.com>
	 <54858B56.1020607@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Li RongQing <roy.qing.li@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:42606 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932138AbaLHPKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 10:10:39 -0500
Received: by mail-ig0-f179.google.com with SMTP id r2so2879832igi.12
        for <netdev@vger.kernel.org>; Mon, 08 Dec 2014 07:10:39 -0800 (PST)
In-Reply-To: <54858B56.1020607@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-12-08 at 14:28 +0300, Sergei Shtylyov wrote:

> 
>     I expect you to also refine the description, so that it's meaningful, 
> unlike now.


It seems obvious to me Li is not a native English speaker. I understood
the patch very well, and the changelog seemed fine to me.

What about you provide this description instead, since you seem to care
very much ?

Thanks !
