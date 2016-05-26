From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 0/4] net/mlx4_en: fix stats
Date: Thu, 26 May 2016 10:24:59 -0700
Message-ID: <1464283499.5939.100.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1464195039-5098-1-git-send-email-edumazet@google.com>
	 <271107bf-61b4-78ec-3c9a-4d57e88fad90@gmail.com>
	 <1464267431.5939.81.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAJ3xEMjoJPSzMp5eOwK6htRAtQHVn-dz6Jn9n9-=TFBW78ChEA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
	Tariq Toukan <ttoukan.linux@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:32962 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752175AbcEZRZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 13:25:03 -0400
Received: by mail-pf0-f177.google.com with SMTP id b124so32856340pfb.0
        for <netdev@vger.kernel.org>; Thu, 26 May 2016 10:25:02 -0700 (PDT)
In-Reply-To: <CAJ3xEMjoJPSzMp5eOwK6htRAtQHVn-dz6Jn9n9-=TFBW78ChEA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-05-26 at 18:19 +0300, Or Gerlitz wrote:
> On Thu, May 26, 2016 at 3:57 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Thu, 2016-05-26 at 12:44 +0300, Tariq Toukan wrote:
> >> Hi Eric,
> >>
> >> > mlx4 has various bugs in its ndo_get_stats() and related functions.
> >> > This patch series address the obvious issues.
> >> > Remaining ones will be discussed later.
> >> >
> >> Thanks for the fixes.
> >> I see they were already applied.
> >> I reviewed them all and replied to patch 4/4, the rest look good to me.
> >> Please CC me as the maintainer of mlx4_en on future patches.
> >
> > If you are mlx4_en maintainer, please submit an official patch so that
> > non Mellanox employees can get this information using the normal way ?
> 
> Eric, sure, we were on a transition period and Tariq was not fully
> familiar with that practice,
> I'd like to make sure the move is finalized internally and then we'll
> send the patch..

Sure ! Please note I gave a polite answer, I am sorry if you felt any
hidden intent from my side.

I did CC the official mlx4_en maintainer on this patch series, by simply
looking at MAINTAINERS file.
