From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: warning: massive change to conditional coding style in net?
Date: Tue, 01 Dec 2009 19:30:14 +0100
Message-ID: <4B1560B6.3020907@gmail.com>
References: <4B13A025.7000103@gmail.com> <20091130.123644.203668577.davem@davemloft.net> <4B1558D8.4010804@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753863AbZLASaP@vger.kernel.org>
In-Reply-To: <4B1558D8.4010804@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

William Allen Simpson a =E9crit :
=20
> If these changes had been mentioned a month or two ago, as part of a
> thorough review, it could have been discussed earlier.  Instead, it's
> like being nibbled by mice.

William,

This is absolutely _not_ possible to comment a 1000+ lines patches in o=
ne shot,
being your patch or not.

It would take _hours_ of work, even for David.

We use a step-by-step process, with limited feedbacks, because nobody i=
s paid
to make your life easier. We patiently gave you a lot of advices and ye=
t
you complain again and again.

After 15/30 minutes of reviewing patches, and collecting some suggestio=
ns,
the average reviewer stops its review, sends a feedback, and waits for =
next
patch submission. [hoping patch author will be pro_active and check all=
 its
patches, not the precise points that were specificaly raised.]

Yes, sometime we notice a point at round eleven, instead of first/secon=
d round,
because more important things were noticed at prior rounds.

I honestly hope you change your mind, or I wont even read your next pat=
ch
submissions, wait for the official RFC and code the damn thing myself o=
r wait for
some kind developper willing to do the job, in the normal process.

You can copy this mail to all man kind, it wont make your patches magic=
ally
ready for inclusion.

Respectfully,
Eric
