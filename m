From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: Re: [PATCH 2/2] net: dummy: allocate devices with alloc_netdev_id
Date: Tue, 7 Jun 2011 11:30:38 +0300
Message-ID: <BANLkTinVNkcznN5kPpje4cptjCKfWW6s-w@mail.gmail.com>
References: <1307410786-19110-1-git-send-email-lucian.grijincu@gmail.com>
 <1307410786-19110-3-git-send-email-lucian.grijincu@gmail.com>
 <1307416765.2642.37.camel@edumazet-laptop> <BANLkTi=8mHr=SaUacW5cFR5xqXPaxrg5Xw@mail.gmail.com>
 <1307433593.3091.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:53221 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752092Ab1FGIbJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2011 04:31:09 -0400
Received: by iwn34 with SMTP id 34so3815546iwn.19
        for <netdev@vger.kernel.org>; Tue, 07 Jun 2011 01:31:08 -0700 (PDT)
In-Reply-To: <1307433593.3091.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 7, 2011 at 10:59 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Please note I was not commenting your patch (it seems fine at a first
> glance), only warning people not doing "modprobe dummy numdummies=3D5=
000"
> without thinking a bit if their machine wont crash or freeze :)


Sorry for fooling you into killing your machine. :))

Later today I'll post a scheduler patch that speeds up the fork bomb to=
o :)

Thank you for the explanation.


@David: I see [1][2] that you marked the patches as Rejected. If it's
not a script that sends all my patches to /dev/null because of the
100+ patch set I sent a while back, could you tell me why you rejected
the patches?

Something fundamentally wrong with them, optimisations that "normal
people" don't care about, etc.?



[1] http://patchwork.ozlabs.org/patch/99065/
[2] http://patchwork.ozlabs.org/patch/99066/
--=20
=C2=A0.
=2E.: Lucian
