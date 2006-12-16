From: Alex Romosan <romosan@sycorax.lbl.gov>
Subject: Re: 2.6.20-rc1 sky2 problems (regression?)
Date: Fri, 15 Dec 2006 17:53:11 -0800
Message-ID: <87odq4y5bs.fsf@sycorax.lbl.gov>
References: <87mz5qnf5q.fsf@sycorax.lbl.gov>
	<E1Gv2kS-0002QY-00@gondolin.me.apana.org.au>
	<20061214192218.35a7f8e1@localhost.localdomain>
	<878xh9rf06.fsf@sycorax.lbl.gov> <20061215172520.62022520@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sycorax.lbl.gov ([128.3.5.196]:3678 "EHLO sycorax.lbl.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753222AbWLPBxS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Dec 2006 20:53:18 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061215172520.62022520@freekitty> (message from Stephen
	Hemminger on Fri, 15 Dec 2006 17:25:20 -0800)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> writes:

> I fixed a bunch of stuff (see ChangeLog) and made a 2.6.19 or later
> version see:
> 	http://developer.osdl.org/shemminger/prototypes/sk98lin-8.41.tar.gz
>
> It is too noisy in the console log, because it shows how many times
> the driver dope slaps itself senseless...  Basically every 250ms when
> it is idle it resets, sorry it's the kind of code you right to "make it work"
> and ship it which is why vendor drivers suck.

i'll give it a try on monday when i go back to work. in the meantime
i've been running with my "fixed" version of the vendor driver and so
far it's been working without any problems (i've been transferring
lots of data in and out of the computer the whole day). if there is
anything i can do to help debug the kernel sky2 driver let me know.

--alex--

-- 
| I believe the moment is at hand when, by a paranoiac and active |
|  advance of the mind, it will be possible (simultaneously with  |
|  automatism and other passive states) to systematize confusion  |
|  and thus to help to discredit completely the world of reality. |
