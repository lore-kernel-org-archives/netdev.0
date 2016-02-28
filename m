From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [net-next-2.6 PATCH v4 1/3] introduce IFE action
Date: Sat, 27 Feb 2016 20:24:33 -0800
Message-ID: <CAM_iQpWbSGCo66HASu1_D9jnRr0X-6-iYFVDmHf8TXNJ1PBR-A@mail.gmail.com>
References: <1456578536-17732-1-git-send-email-jhs@emojatatu.com>
	<1456578536-17732-2-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f181.google.com ([209.85.161.181]:33441 "EHLO
	mail-yw0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992685AbcB1EYe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2016 23:24:34 -0500
Received: by mail-yw0-f181.google.com with SMTP id u200so98279907ywf.0
        for <netdev@vger.kernel.org>; Sat, 27 Feb 2016 20:24:34 -0800 (PST)
In-Reply-To: <1456578536-17732-2-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 27, 2016 at 5:08 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> This action allows for a sending side to encapsulate arbitrary metadata
> which is decapsulated by the receiving end.
> The sender runs in encoding mode and the receiver in decode mode.
> Both sender and receiver must specify the same ethertype.
> At some point we hope to have a registered ethertype and we'll
> then provide a default so the user doesnt have to specify it.
> For now we enforce the user specify it.
>

[...]

>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>

Thanks for updating it!
