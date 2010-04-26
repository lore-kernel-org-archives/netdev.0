From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 2/2] net: reimplement softnet_data.output_queue as a FIFO
	queue
Date: Mon, 26 Apr 2010 17:11:25 +0800
Message-ID: <q2p412e6f7f1004260211t19efd3ebk183577ac4a39d31e@mail.gmail.com>
References: <1272252361-11799-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f202.google.com ([209.85.223.202]:46968 "EHLO
	mail-iw0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750798Ab0DZJNy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 05:13:54 -0400
Received: by iwn40 with SMTP id 40so3048838iwn.1
        for <netdev@vger.kernel.org>; Mon, 26 Apr 2010 02:13:54 -0700 (PDT)
In-Reply-To: <1272252361-11799-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 26, 2010 at 11:26 AM, Changli Gao <xiaosuo@gmail.com> wrote=
:
> reimplement softnet_data.output_queue as a FIFO queue.
>
> reimplement softnet_data.output_queue as a FIFO queue to keep the fai=
rness among
> the qdiscs rescheduled.
>

Dear Eric:
  do you think it is worth continuing? I didn't received any comments
even negative ones. I am really sorry for disrupting you, but I don't
know what did it mean.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
