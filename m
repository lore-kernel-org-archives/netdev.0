From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bug #14925] sky2 panic under load
Date: Tue, 12 Jan 2010 10:31:07 +0000
Message-ID: <20100112103107.GC6628@ff.dom.local>
References: <20100112075059.GA6628@ff.dom.local> <20100112.000804.186755338.davem@davemloft.net> <20100112085633.GB6628@ff.dom.local> <20100112.014218.112731835.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, mikem@ring3k.org, flyboy@gmail.com,
	rjw@sisk.pl, netdev@vger.kernel.org, mbreuer@majjas.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:51219 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754019Ab0ALKbP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 05:31:15 -0500
Received: by fxm25 with SMTP id 25so473656fxm.21
        for <netdev@vger.kernel.org>; Tue, 12 Jan 2010 02:31:14 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20100112.014218.112731835.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 12, 2010 at 01:42:18AM -0800, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Tue, 12 Jan 2010 08:56:34 +0000
> 
> > Maybe I miss something, but once more: this patch mentioned by Berck
> > Nash has been tested by at least two users, Berck himself, and
> > probably even more intensively by Michael Breuer, during af_packet
> > debugging. Both guys acknowledged it helped, so it can't be that bad.
> 
> I agree, as a short term fix, this patch is fine.

And I agree real problems might be deeper.

Jarek P.
