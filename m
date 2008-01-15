From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: questions on NAPI processing latency and dropped network
	packets
Date: Tue, 15 Jan 2008 21:29:05 +0100
Message-ID: <20080115202905.GA2680@ami.dom.local>
References: <20080115071950.GA1696@ff.dom.local> <478CC76B.1020804@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:64115 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751700AbYAOU0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 15:26:14 -0500
Received: by fg-out-1718.google.com with SMTP id e21so2791528fga.17
        for <netdev@vger.kernel.org>; Tue, 15 Jan 2008 12:26:11 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <478CC76B.1020804@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 15, 2008 at 08:47:07AM -0600, Chris Friesen wrote:
> Jarek Poplawski wrote:
>
>> IMHO, checking this with a current stable, which probably you are going
>> to do some day, anyway, should be 100% acceptable: giving some input to
>> netdev, while still working for yourself.
>
> While I would love to do this, it's not that simple.

...Hmm... As a matter of fact, I expected you'd treat my point less
literally... Of course, I know it could be sometimes very hard to get
something working even after upgrading one version, let alone several
at once.

So, it was more a rhetorical trick (sorry!) to suggest, that such a
business model of being always late with kernels might be quite
practical and reasonable for many companies, but looks like the
worst possible development model for Linux.

On the other hand, it seems there are not so much, nor expensive
changes needed (a bit more perspective thinking?) to make everybody
happy...

Jarek P.
