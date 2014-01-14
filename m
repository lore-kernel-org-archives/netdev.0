From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] usbnet: Fix dma setup for fragmented packets that need a pad byte appended.
Date: Tue, 14 Jan 2014 16:48:21 +0100
Message-ID: <87vbxm7eey.fsf@nemi.mork.no>
References: <063D6719AE5E284EB5DD2968C1650D6D45B28F@AcuExch.aculab.com>
	<1389710518.31367.259.camel@edumazet-glaptop2.roam.corp.google.com>
	<063D6719AE5E284EB5DD2968C1650D6D45B492@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "'Eric Dumazet'" <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:54589 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751634AbaANPsa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 10:48:30 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D45B492@AcuExch.aculab.com>
	(David Laight's message of "Tue, 14 Jan 2014 14:48:23 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Laight <David.Laight@ACULAB.COM> writes:

> I couldn't find the original patch anywhere!
> I did do quite a lot of looking as well - if I'd found it I've
> have done something else.

You obviously haven't looked the one place you are supposed to always
look before submitting *anything*:
https://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=3D=
fdc3452cd2c7b2bfe0f378f92123f4f9a98fa2bd

I am not impressed...



Bj=C3=B8rn
