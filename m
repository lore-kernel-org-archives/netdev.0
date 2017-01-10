From: Joe Perches <joe@perches.com>
Subject: Re: [net-next PATCH 1/3] Revert "icmp: avoid allocating large
 struct on stack"
Date: Tue, 10 Jan 2017 13:41:51 -0800
Message-ID: <1484084511.12006.7.camel@perches.com>
References: <1483985224.21472.3.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170109.135259.988711786570465428.davem@davemloft.net>
         <CAM_iQpUbcVogq7jGePkgPJ0z_J=46hnK8KcTiX1svVXr1Hoh-w@mail.gmail.com>
         <20170110.131223.748150430551443881.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, brouer@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0139.hostedemail.com ([216.40.44.139]:57896 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752620AbdAJVl4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 16:41:56 -0500
In-Reply-To: <20170110.131223.748150430551443881.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-01-10 at 13:12 -0500, David Miller wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> Date: Tue, 10 Jan 2017 10:06:01 -0800
> 
> > On Mon, Jan 9, 2017 at 10:52 AM, David Miller <davem@davemloft.net> wrote:
> >> From: Eric Dumazet <eric.dumazet@gmail.com>
> >> Date: Mon, 09 Jan 2017 10:07:04 -0800
> >>
> >>> You really should come to netdev conferences so that you understand
> >>> goals and efforts, instead of living in your cave.
> >>
> >> I completely agree with Eric.
> >>
> >> Cong we have a very serious problem with you exactly because you make
> >> quite vicious emotional statements targetted at other developers

"quite vicious" is overstatement here.

> >> merely when they say something you disagree with.
> > 
> > What emotional? Pointing out Eris's words from 4 years ago is NOT
> > emotional, it is just a help.

Not really.  Your "facepalm" didn't seem to be written as
humor but more as an expression of your exasperation.

> Saying "Facepalm" is emotional and has nothing to do with the
> technical issues.

Many words are emotional or conflictual.

Saying "stupid" is emotional and also has no technical content.

Stupid is used here all the time.  Happily, it's generally used
as a reference to self and not about others.

However it is still occasionally and unfortunately used when
referencing proposed code or other person's behaviors.

Thankfully, these types of words are being used less and less
in discussions here.

I agree with David and Eric that it's generally better to avoid
these word choices.
