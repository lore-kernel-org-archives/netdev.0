From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v9 00/11] vxlan: add ipv6 support
Date: Tue, 28 May 2013 10:42:58 +0800
Message-ID: <1369708978.8181.39.camel@cr0>
References: <1369628193-14925-1-git-send-email-amwang@redhat.com>
	 <87a9ngddfv.fsf@nemi.mork.no> <8761y4dcm7.fsf@nemi.mork.no>
	 <20130527.023039.165030551447378095.davem@davemloft.net>
	 <1369652446.8181.10.camel@cr0> <87ehcsbmfk.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25502 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758630Ab3E1CnI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 May 2013 22:43:08 -0400
In-Reply-To: <87ehcsbmfk.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-05-27 at 15:07 +0200, Bj=C3=B8rn Mork wrote:
> Cong Wang <amwang@redhat.com> writes:
>=20
> > On Mon, 2013-05-27 at 02:30 -0700, David Miller wrote:
> >>=20
> >> And you had the nerve to complain when we were unwilling to merge =
this
> >> not-ready garbage into 3.10?!?!  Are you kidding me?=20
> >
> > Please fix the netfilter erorrs too:
> >
> > http://marc.info/?l=3Dnetfilter-devel&m=3D136849956816787&w=3D2
> >
> > which were reported by me two weeks ago, NO ONE cares!
>=20
> I am pretty sure you are wrong about that.

It is true that no one replies to my report, maybe someone fixed it
without Cc'ing me, but how could I know that since my RH email doesn't
subscribe any mailing list.

>=20
> > Just complaining about vxlan seems unfair. :)
>=20
> Would you prefer that I didn't report this bug?  Do you believe the
> existence of other bugs means that you don't need to test your patche=
s?
> Are your for real?

Obviously no, you take a wrong point.

My point is you should care other IPV6=3Dm errors as much as you care f=
or
vxlan ones. I don't see any reply from you when I reported the netfilte=
r
errors, even after two weeks! For me this sounds like you are ignoring
them on purpose, although I don't mind...

>=20
> Give me one reason why I should bother even looking at your next
> submission.  Just to make it clear:  No comments from me the next tim=
e
> you post this set only means that I didn't test it.  Which seems
> likely given your ability to take any feedback at all.

You said "I see that you don't bother listen to advice", this is
OBVIOUSLY not true, I really did compile with three different configs,
just due a stupid mistake I took my IPV6=3Dn config as IPV6=3Dm config.

Your conclusion like this one is really offending, and I can't see any
respect for my work from your reply.

I am sorry for my mistake, and I always welcome for any feedbacks, but
just please be with respect. If next time I still see offending reply
like this, I will just ignore you. Sorry, but this is my right. :(
