From: Samuel Ortiz <samuel@sortiz.org>
Subject: Re: IrDA woes..
Date: Sat, 04 Jan 2014 02:23:31 +0100
Message-ID: <1388798611.4326.11.camel@zurbaran>
References: <CA+55aFz2CQ4B1JSpQ75TuQrrd9sUnhV+u=T2dWZY2NTTT5OmpQ@mail.gmail.com>
	 <20140102.034653.1968429090467668489.davem@davemloft.net>
	 <CA+55aFz_qDYP_P0PLUNv0wotoy=5PcS+7Qtt=U6EzvL4h4E69A@mail.gmail.com>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:57732 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753866AbaADBX6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 20:23:58 -0500
In-Reply-To: <CA+55aFz_qDYP_P0PLUNv0wotoy=5PcS+7Qtt=U6EzvL4h4E69A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Linus,

On Thu, 2014-01-02 at 11:11 -0800, Linus Torvalds wrote:
> The odd thing is that I *have* seen it work, a couple of times, so
> it's not like it *never* works (in which case I'd just think that the
> above simply isn't even supposed to work at all), but the "it actually
> worked" is a very rare occurrence. Most of the time opening the ircomm
> blocks. But sometimes it works after a few seconds. Very odd.
I'm pretty sure the stack was never designed nor tested for that kind of
usage, so I'm even surprised it ever worked for you.

> Samuel is listed as maintainer, but I'm getting the feeling he has
> long since moved on.
That's correct, and the MAINTAINERS file should be updated I guess.
The combination of my last IrDA enabled phone dying and the IrDA
association removing my access to the specs significantly lowered my
interest.

Cheers,
Samuel.
