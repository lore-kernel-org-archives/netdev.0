From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next-2.6 PATCH v4 3/3] TCPCT part 1c: initial SYN exchange
 with SYNACK data
Date: Mon, 02 Nov 2009 12:50:01 -0500
Message-ID: <4AEF1BC9.6090005@gmail.com>
References: <4AE6E35C.2050101@gmail.com> <4AE6E7C0.2050408@gmail.com>	 <4AEDDF33.9030205@gmail.com>  <4AEECFA8.1080306@gmail.com> <1257181219.28925.13.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:6351 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751813AbZKBRuB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 12:50:01 -0500
Received: by fg-out-1718.google.com with SMTP id 16so68099fgg.1
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2009 09:50:05 -0800 (PST)
In-Reply-To: <1257181219.28925.13.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches wrote:
> Linus wrote a long time back (5+ years):
> 
> The reason for "if (x == 8)" comes from the way we're taught to think. 
> Arguing against that _fact_ is just totally non-productive, and you have 
> to _force_ yourself to write it the other way around.
> 
Interesting.  I've not been able to Google this quote.

I actually think as I write it, finding the other ragged and hard to
visually review.  But apparently it's an issue for ESL or something,
taught to think in another way.

Therefore, I'll re-code as Linus has prescribed.  Sadly, I'm having
very bad luck verifying coding examples by checking against the
installed base, as I found thousands of lines following more usual
secure coding practices....

Thank you.
