From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net 0/4] net/mlx4_en: fix stats
Date: Thu, 26 May 2016 18:19:34 +0300
Message-ID: <CAJ3xEMjoJPSzMp5eOwK6htRAtQHVn-dz6Jn9n9-=TFBW78ChEA@mail.gmail.com>
References: <1464195039-5098-1-git-send-email-edumazet@google.com>
	<271107bf-61b4-78ec-3c9a-4d57e88fad90@gmail.com>
	<1464267431.5939.81.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tariq Toukan <ttoukan.linux@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:33672 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753643AbcEZPTf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 11:19:35 -0400
Received: by mail-oi0-f47.google.com with SMTP id k23so129442403oih.0
        for <netdev@vger.kernel.org>; Thu, 26 May 2016 08:19:35 -0700 (PDT)
In-Reply-To: <1464267431.5939.81.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 26, 2016 at 3:57 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2016-05-26 at 12:44 +0300, Tariq Toukan wrote:
>> Hi Eric,
>>
>> > mlx4 has various bugs in its ndo_get_stats() and related functions.
>> > This patch series address the obvious issues.
>> > Remaining ones will be discussed later.
>> >
>> Thanks for the fixes.
>> I see they were already applied.
>> I reviewed them all and replied to patch 4/4, the rest look good to me.
>> Please CC me as the maintainer of mlx4_en on future patches.
>
> If you are mlx4_en maintainer, please submit an official patch so that
> non Mellanox employees can get this information using the normal way ?

Eric, sure, we were on a transition period and Tariq was not fully
familiar with that practice,
I'd like to make sure the move is finalized internally and then we'll
send the patch..

On a somehow related note, Dave, Eric's patches were sent after our Wed working
hours ended and accepted before our Thu working hours started.. could we get a
better chance to review driver patches before acceptance?  I know
there were times
where we've screwed up and things didn't get fast attention, but we're
working to improve
so... get us a chance [1]?

Or.

[1] when it comes to weekends, the IL WW ends on Thu when the US WW
has almost two
full days to go (Thu, Fri), so here the response latency might be
bigger, but Sun-Thu we should
be responding on the same day.
