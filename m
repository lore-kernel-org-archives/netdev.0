From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: Re: 2.6.32-rc5-mmotm1101 - kernel BUG at net/ipv4/tcp_input.c:3707!
Date: Tue, 03 Nov 2009 21:20:50 +0200
Message-ID: <4AF08292.7090102@codefidence.com>
References: <5765.1257270611@turing-police.cc.vt.edu> <4AF07024.80103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Ori Finkelman <ori@comsleep.com>
To: Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenbox.codefidence.com ([92.48.73.16]:42232 "EHLO
	xenbox.codefidence.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753324AbZKCTVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 14:21:06 -0500
In-Reply-To: <4AF07024.80103@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:

> Valdis.Kletnieks@vt.edu a =E9crit :
>  =20
>> Seen right after I started 'fetchmail'.  Reproducible - 3 out of 3.
>> I'll bisect this tonight if nobody jumps up and yells they know what=
 it is...
>>    =20
Bah... this is most probably my fault. Sorry about that.

Can you please try the patch in the next email?

But also, can you please send me the route table in effect when this=20
happened and the fetchmail command line/config (removing any passwords=20
or account details of course)? I want to understand better when this=20
happens.

Thanks!
Gilad


--=20
Gilad Ben-Yossef
Chief Coffee Drinker & CTO
Codefidence Ltd.

Web:   http://codefidence.com
Cell:  +972-52-8260388
Skype: gilad_codefidence
Tel:   +972-8-9316883 ext. 201
=46ax:   +972-8-9316884
Email: gilad@codefidence.com

Check out our Open Source technology and training blog - http://tuxolog=
y.net

	"The biggest risk you can take it is to take no risk."
		-- Mark Zuckerberg and probably others

