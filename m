From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next v2] packet: packet fanout rollover during socket overload
Date: Mon, 18 Mar 2013 19:36:58 -0400
Message-ID: <CA+FuTSeKTowMBD1Pu7Ox3K+-Tis+Ze17Phky0FocwEpa=Wwbvw@mail.gmail.com>
References: <1363648051-5976-1-git-send-email-willemb@google.com>
 <1363648249.21184.11.camel@edumazet-glaptop> <CA+FuTSfvG8Wzn9Q12V-wsuzXv-VTth4NEkX1kFqdFKe42A-+9Q@mail.gmail.com>
 <1363649282.21184.12.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:39858 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753223Ab3CRXh3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 19:37:29 -0400
Received: by mail-wg0-f54.google.com with SMTP id fm10so5332593wgb.33
        for <netdev@vger.kernel.org>; Mon, 18 Mar 2013 16:37:28 -0700 (PDT)
In-Reply-To: <1363649282.21184.12.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Will resend after rebase + testing.

On Mon, Mar 18, 2013 at 7:28 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2013-03-18 at 19:16 -0400, Willem de Bruijn wrote:
>
>> Thanks Eric.
>>
>> I need to rebase the patch once more to have it apply cleanly.
>
> Oh right, include/linux/if_packet.h was moved
> to include/uapi/linux/if_packet.h

Yes. I found another way to mess up a patch. Have rebased it already
and it compiles fine, but I want to test it, just to be sure. Will send
tomorrow with no other changes if nothing shows up.

>
>
>
