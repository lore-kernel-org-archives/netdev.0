From: Mark Lord <lkml@rtr.ca>
Subject: Re: 2.6.25-rc8: FTP transfer errors
Date: Fri, 11 Apr 2008 09:19:17 -0400
Message-ID: <47FF6555.50004@rtr.ca>
References: <47FEADCB.7070104@rtr.ca> <20080410.172453.44434205.davem@davemloft.net> <47FEB062.3020003@rtr.ca> <20080410.173911.179180620.davem@davemloft.net> <47FEBDAA.7010305@rtr.ca> <Pine.LNX.4.64.0804110849520.28360@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jesper.juhl@gmail.com,
	tilman@imap.cc, yoshfuji@linux-ipv6.org,
	Jeff Garzik <jeff@garzik.org>, rjw@sisk.pl,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: =?UTF-8?B?SWxwbyBKw6RydmluZW4=?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtr.ca ([76.10.145.34]:1031 "EHLO mail.rtr.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751768AbYDKNTW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2008 09:19:22 -0400
In-Reply-To: <Pine.LNX.4.64.0804110849520.28360@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=C3=A4rvinen wrote:
> On Thu, 10 Apr 2008, Mark Lord wrote:
>=20
>> David Miller wrote:
>>> From: Mark Lord <lkml@rtr.ca>
>>> Date: Thu, 10 Apr 2008 20:27:14 -0400
>>>
>>>> It's *your* bug -- you signed off on the commit.
>>> I sign off on basically every networking commit, does that mean I h=
ave
>>> to fix every networking bug and every networking bug is "mine"?
>> ..
>>
>> Absolutely, though to a varying degree.  That's the responsibility
>> that goes with the role of a subsystem maintainer.  I once had
>> such a role, and gave it up when I felt I could no longer keep up. =20
>> You still keep refering to it as "your (my) bug".
>> It's not.  I had nothing to do with it, other than stumbling over it=
=2E
>=20
> This bug is perfect example where bisect clearly was useful :-). Nobo=
dy=20
> knew whose bug it actually was until your bisect gave directions.
>=20
>> When people stumble over a libata bug, I look hard to see if my code
>> could possibly cause it.  Jeff looks even harder, because he's the
>> current subsystem dude for libata.
>>
>> I never suggest a user search through a mountain of unrelated commit=
s
>> for something I've screwed up on.
>=20
> But it is ok for you to ask an innocent net developer to do that (eve=
n=20
> with your terms as I hadn't signed off _anything_ related to that one=
),
> hmm?
>=20
> ...You had this pretty demanding tone earlier:
>=20
>> Or I can ignore it, like the net developers, since I have a workarou=
nd.
>> And then we'll see what other apps are broken upon 2.6.25 final rele=
ase.
=2E.

That's not demanding, that's quite relaxed.  I had a good workaround,
and didn't really care any more at that point.  Just though it was rath=
er
odd that none of the developers seemed interested in tracking it down.
I offered tons of help, gave it, and said I didn't have time for a full
bisect at that juncture.

=46or that, I get repeatedly slammed by the netdev folks.
Even after I put aside *paid* work to submit to your demands.

Next time around, I won't bother reporting bugs to you folks,
that's for damned sure.

Cheers
