From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Subject: Re: [PATCH] packet: Allow packets with only a header (but no payload)
Date: Tue, 28 Jul 2015 00:35:56 +0200
Message-ID: <CAFBinCDZDYJGjimsAD=+HFokc9ga0cLBD1KSAieagzWQNH+s=w@mail.gmail.com>
References: <1437495247-471-1-git-send-email-martin.blumenstingl@googlemail.com>
 <CA+FuTScr0o0ZmwWxVP4FZoQosRRiQG6+MDvCahMCWmjLkg+33g@mail.gmail.com>
 <CAFBinCB4xOBzxwkEQYrpi1q7Xm4_-hpj2jUE2r-fQ5f2grjZ=Q@mail.gmail.com> <CA+FuTSctXr=2eC_-e793hvAPu=XyEhLeLoowH95tbOBx8CGj7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	David Miller <davem@davemloft.net>, johann.baudy@gnu-log.net
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:35485 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754546AbbG0WgR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 18:36:17 -0400
Received: by lahh5 with SMTP id h5so57796902lah.2
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 15:36:16 -0700 (PDT)
In-Reply-To: <CA+FuTSctXr=2eC_-e793hvAPu=XyEhLeLoowH95tbOBx8CGj7g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johann,

On Tue, Jul 21, 2015 at 6:51 PM, Willem de Bruijn <willemb@google.com> wrote:
> I don't see a simple way of verifying the safety of allowing packets
> without data short of a code audit, which would be huge, especially
> when taking device driver logic into account. Perhaps someone
> remembers why that statement was added and what edge case(s)
> it refers to. I'm afraid that I don't. It was added in 69e3c75f4d54. I
> added the author to this thread.
I know it's summer (and thus vacation-time), but did you already have
a chance to look into this?


Regards,
Martin
