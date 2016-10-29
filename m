From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH net] net: mangle zero checksum in skb_checksum_help()
Date: Sat, 29 Oct 2016 11:30:41 -0700
Message-ID: <CANP3RGeA+0QL4xdV4=b+sm8NCvwontnuRWbthLdGCrggMG0apQ@mail.gmail.com>
References: <1477764156.7065.282.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f174.google.com ([209.85.161.174]:35345 "EHLO
        mail-yw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751292AbcJ2Sam (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2016 14:30:42 -0400
Received: by mail-yw0-f174.google.com with SMTP id h14so115614980ywa.2
        for <netdev@vger.kernel.org>; Sat, 29 Oct 2016 11:30:42 -0700 (PDT)
In-Reply-To: <1477764156.7065.282.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: Maciej =C5=BBenczykowski <maze@google.com>
