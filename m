From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net-next] net: remove useless check in napi_gro_frags()
Date: Thu, 19 Nov 2015 21:20:05 +0100
Message-ID: <87oaepzqq2.fsf@nemi.mork.no>
References: <1447962170.22599.240.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151119195419.GA6728@ast-mbp.thefacebook.com>
	<1447964139.22599.246.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:59329 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934419AbbKSUUN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 15:20:13 -0500
In-Reply-To: <1447964139.22599.246.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Thu, 19 Nov 2015 12:15:39 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> How many times should we crash before napi_frags_skb() returns NULL ?
=2E.
>                         return NULL;

Huh?  Now I'm lost here, too.


Bj=C3=B8rn
