From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] packet: packet fanout rollover during
 socket overload
Date: Mon, 18 Mar 2013 16:28:02 -0700
Message-ID: <1363649282.21184.12.camel@edumazet-glaptop>
References: <1363648051-5976-1-git-send-email-willemb@google.com>
	 <1363648249.21184.11.camel@edumazet-glaptop>
	 <CA+FuTSfvG8Wzn9Q12V-wsuzXv-VTth4NEkX1kFqdFKe42A-+9Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:33572 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753170Ab3CRX2G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 19:28:06 -0400
Received: by mail-pb0-f51.google.com with SMTP id un15so6810278pbc.38
        for <netdev@vger.kernel.org>; Mon, 18 Mar 2013 16:28:05 -0700 (PDT)
In-Reply-To: <CA+FuTSfvG8Wzn9Q12V-wsuzXv-VTth4NEkX1kFqdFKe42A-+9Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-03-18 at 19:16 -0400, Willem de Bruijn wrote:

> Thanks Eric.
> 
> I need to rebase the patch once more to have it apply cleanly.

Oh right, include/linux/if_packet.h was moved
to include/uapi/linux/if_packet.h
