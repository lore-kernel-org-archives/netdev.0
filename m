From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v3] tcp: Add a TCP_FASTOPEN socket option to get a max
 backlog on its listner
Date: Fri, 18 Apr 2014 20:42:28 -0400
Message-ID: <CADVnQyn-cxWv_5qd8ZwVyrty=PQr-aw2e7kVWgt+rA9_Jt5QJg@mail.gmail.com>
References: <87a9bljl7m.fsf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Kenjiro Nakayama <nakayamakenjiro@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:33269 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752764AbaDSAma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2014 20:42:30 -0400
Received: by mail-wg0-f49.google.com with SMTP id a1so1000030wgh.32
        for <netdev@vger.kernel.org>; Fri, 18 Apr 2014 17:42:29 -0700 (PDT)
In-Reply-To: <87a9bljl7m.fsf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 16, 2014 at 12:25 PM, Kenjiro Nakayama
<nakayamakenjiro@gmail.com> wrote:
> This patch adds a TCP_FASTOPEN socket option to get a max backlog on its
> listener to getsockopt().
>
> Signed-off-by: Kenjiro Nakayama <nakayamakenjiro@gmail.com>
> ---
>  net/ipv4/tcp.c | 8 ++++++++
>  1 file changed, 8 insertions(+)

Acked-by: Neal Cardwell <ncardwell@google.com>

Seems fine to me. Thanks, Kenjiro.

neal
