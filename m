From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH v5] net: ethernet: add driver for Aurora VLSI NB8800 Ethernet controller
Date: Wed, 11 Nov 2015 13:48:52 +0000
Message-ID: <yw1x1tbwpry3.fsf@unicorn.mansr.com>
References: <1447172063-27234-1-git-send-email-mans@mansr.com>
	<20151110233448.GA8646@electric-eye.fr.zoreil.com>
	<yw1xio59pdw6.fsf@unicorn.mansr.com>
	<20151110.211121.422193831316296487.davem@davemloft.net>
	<yw1xa8qkpvy3.fsf@unicorn.mansr.com>
	<yw1x6118pu0o.fsf@unicorn.mansr.com>
	<1447248595.17135.98.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, romieu@fr.zoreil.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	slash.tmp@free.fr
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from unicorn.mansr.com ([81.2.72.234]:44261 "EHLO unicorn.mansr.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752274AbbKKNtD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2015 08:49:03 -0500
In-Reply-To: <1447248595.17135.98.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Wed, 11 Nov 2015 05:29:55 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> On Wed, 2015-11-11 at 13:04 +0000, M=E5ns Rullg=E5rd wrote:
>
>> I tried that, and throughput (as measured by iperf3) dropped by 2%.
>> Maybe I did something wrong.
>
> What link speed have you used, what was the throughput you got,
> and is the receiver using the same NIC ?

1Gbps link, 640 Mbps TCP transmit throughput to a PC with Intel NIC.
Why does it matter what NIC the receiver has?

--=20
M=E5ns Rullg=E5rd
mans@mansr.com
