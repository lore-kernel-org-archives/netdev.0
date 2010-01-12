From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bug #14925] sky2 panic under load
Date: Tue, 12 Jan 2010 11:04:22 +0000
Message-ID: <20100112110422.GD6628@ff.dom.local>
References: <20100112.000804.186755338.davem@davemloft.net> <20100112085633.GB6628@ff.dom.local> <20100112.014218.112731835.davem@davemloft.net> <20100112.025620.210305029.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, mikem@ring3k.org, flyboy@gmail.com,
	rjw@sisk.pl, netdev@vger.kernel.org, mbreuer@majjas.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:49409 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754043Ab0ALLEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 06:04:30 -0500
Received: by fg-out-1718.google.com with SMTP id 19so9285222fgg.1
        for <netdev@vger.kernel.org>; Tue, 12 Jan 2010 03:04:29 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20100112.025620.210305029.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 12, 2010 at 02:56:20AM -0800, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Tue, 12 Jan 2010 01:42:18 -0800 (PST)
> 
> > From: Jarek Poplawski <jarkao2@gmail.com>
> > Date: Tue, 12 Jan 2010 08:56:34 +0000
> > 
> >> Maybe I miss something, but once more: this patch mentioned by Berck
> >> Nash has been tested by at least two users, Berck himself, and
> >> probably even more intensively by Michael Breuer, during af_packet
> >> debugging. Both guys acknowledged it helped, so it can't be that bad.
> > 
> > I agree, as a short term fix, this patch is fine.
> 
> In case it isn't painfully obvious, I'm applying Jarek's "v2"
> fix and will also queue that up for -stable.
> 

Thanks!
Jarek P.
