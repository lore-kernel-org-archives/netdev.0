From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: questions on NAPI processing latency and dropped network
	packets
Date: Tue, 15 Jan 2008 08:19:50 +0100
Message-ID: <20080115071950.GA1696@ff.dom.local>
References: <478B86BA.1050706@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:49678 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752369AbYAOHNb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 02:13:31 -0500
Received: by ug-out-1314.google.com with SMTP id z38so42783ugc.16
        for <netdev@vger.kernel.org>; Mon, 14 Jan 2008 23:13:29 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <478B86BA.1050706@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14-01-2008 16:58, Chris Friesen wrote:
...
> How close to bleeding edge do we need to be for it to be considered 
> acceptable to ask questions on netdev?
> 
> Given that the embedded space tends to be perpetually stuck on older 
> kernels (our "current" release is based on 2.6.14) do you have any 
> suggestion on how we can obtain information that would be available on 
> netdev if we were using newer kernels?

IMHO, checking this with a current stable, which probably you are going
to do some day, anyway, should be 100% acceptable: giving some input to
netdev, while still working for yourself.

Regards,
Jarek P.
