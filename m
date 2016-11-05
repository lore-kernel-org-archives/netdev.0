From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH net] sock: fix sendmmsg for partial sendmsg
Date: Fri, 4 Nov 2016 20:10:31 -0700
Message-ID: <CAHo-Oox2Ae+p7gSnFBe-7N675aAomm8q-+Xig18S-2UCGw_U_g@mail.gmail.com>
References: <1478288209-30893-1-git-send-email-soheil.kdev@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>,
        Linux NetDev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f173.google.com ([209.85.213.173]:35762 "EHLO
        mail-yb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752812AbcKEDKc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 23:10:32 -0400
Received: by mail-yb0-f173.google.com with SMTP id d128so38403249ybh.2
        for <netdev@vger.kernel.org>; Fri, 04 Nov 2016 20:10:32 -0700 (PDT)
In-Reply-To: <1478288209-30893-1-git-send-email-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: Maciej =C5=BBenczykowski <maze@google.com>
