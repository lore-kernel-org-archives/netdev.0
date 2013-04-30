From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v7 4/6] vxlan: add ipv6 support
Date: Tue, 30 Apr 2013 14:58:30 -0400 (EDT)
Message-ID: <20130430.145830.1069552594749915607.davem@davemloft.net>
References: <1367311395-15891-5-git-send-email-amwang@redhat.com>
	<87r4hscr7s.fsf@nemi.mork.no>
	<1367314694.3216.25.camel@cr0>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bjorn@mork.no, netdev@vger.kernel.org, dlstevens@us.ibm.com,
	stephen@networkplumber.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52030 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933275Ab3D3S6d convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 14:58:33 -0400
In-Reply-To: <1367314694.3216.25.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Cong Wang <amwang@redhat.com>
Date: Tue, 30 Apr 2013 17:38:14 +0800

> On Tue, 2013-04-30 at 11:17 +0200, Bj=F8rn Mork wrote:
>> There is no need to rush
>> this, and people may get tired of looking at the same shortcomings
>> over
>> and over again.=20
>=20
> The sooner it gets merged, the less maintaining pains I have. I have =
to
> solve many conflicts _every time_ I rebase it on to the latest net-ne=
xt.

You can't force a feature to be ready, when it isn't.  And your
complaints about merge conflicts are falling on deaf ears.

If you're frustrated, it's entirely a self inflicted wound.  And I
absolutely will not stop the people doing work that is ready just
because you have this patch series which conflicts, but isn't ready.

You have to understand that if this patch series didn't have so many
shortcomings every single submission, it would have been merged weeks
ago.

But that's not what happened, and therefore you're going to miss this
merge window, and you're going to have to be at peace with that.

net-next is closed, I said it's closed, and I even was nicer than
usual by merging in stuff that came in on the last day.

You have no basis upon which to justify merging vxlan ipv6 support in
this merge window, none.

So the earliest you'll be able to resubmit this feature is about two
weeks from now when I re-open net-next.  That gives you plenty of time
to correct all of the bugs and semantic problems, rather than trying
to "rush" it into my tree.  Rush is synonymous with buggy and not well
cared for, two things I'd like to avoid.
