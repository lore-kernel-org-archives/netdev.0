From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] usbnet: Fix dma setup for fragmented packets that need a pad byte appended.
Date: Tue, 14 Jan 2014 19:51:10 +0100
Message-ID: <87mwiy75y9.fsf@nemi.mork.no>
References: <063D6719AE5E284EB5DD2968C1650D6D45B28F@AcuExch.aculab.com>
	<1389710518.31367.259.camel@edumazet-glaptop2.roam.corp.google.com>
	<063D6719AE5E284EB5DD2968C1650D6D45B492@AcuExch.aculab.com>
	<87vbxm7eey.fsf@nemi.mork.no>
	<063D6719AE5E284EB5DD2968C1650D6D45B744@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "'Eric Dumazet'" <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:57105 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751038AbaANSvQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 13:51:16 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D45B744@AcuExch.aculab.com>
	(David Laight's message of "Tue, 14 Jan 2014 17:28:27 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Laight <David.Laight@ACULAB.COM> writes:
> From: Bj=C3=B8rn Mork [mailto:bjorn@mork.no]
>> David Laight <David.Laight@ACULAB.COM> writes:
>>=20
>> > I couldn't find the original patch anywhere!
>> > I did do quite a lot of looking as well - if I'd found it I've
>> > have done something else.
>>=20
>> You obviously haven't looked the one place you are supposed to alway=
s
>> look before submitting *anything*:
>> https://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?i=
d=3Dfdc3452cd2c7b2bfe0f378f92123f4f9
>> a98fa2bd
>>=20
>> I am not impressed...
>
> Without the commit id that is rather hard.

I suggest you stop this nonsense now.

If you are going to submit a patch for "net", then the last thing you d=
o
is check out net/master and rebase on top of it.  If you had done so,
then you would have noticed the conflict.  You never need to know the
commit id.  Where the heck do you think I got it?

> Does anything even get there without manual actions.
> usb patches sit in a hidden limbo for ages.
>
> I looked through my mailboxes and searched for the thread - but only
> found the messages that included the one that said you'd send a patch
> soon.
>
> What I still don't understand is how I found the patch before!

Does it matter?  You obviously knew you were posting a duplicate.  Ther=
e
is no excuse for that.  Duplicates do *not* help.  Whether you are able
to find the original or not doesn't matter.  The rest of the world is.
Duplicate are confusing.  Confusion cause delays and noise.  I assume
you don't want either.

> The fact that work make me use outluck makes searching mail locally
> almost impossible.

Your lack of proper tools is your problem...

Now I know I come out a bit harsh.  I can't help it.  It's not that I
care much about whether or not I am credited for this oneliner, and you
did credit me in any case. But this whole discussion is so completely
unnecessary.  Just use patchwork to track the status of patches you are
interested in. If you can't find a patch there, then YOU are doing
something wrong.  It's as simple as that. No excuse.


Bj=C3=B8rn
