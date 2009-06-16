From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: net: fix network drivers ndo_start_xmit() return values
Date: Tue, 16 Jun 2009 07:12:04 +0000
Message-ID: <20090616071204.GB4494@ff.dom.local>
References: <4A367E14.4040104@trash.net> <20090616061603.GA4494@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, perex@perex.cz
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:65001 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756007AbZFPHMI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 03:12:08 -0400
Received: by fg-out-1718.google.com with SMTP id d23so550516fga.17
        for <netdev@vger.kernel.org>; Tue, 16 Jun 2009 00:12:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090616061603.GA4494@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 16, 2009 at 06:16:03AM +0000, Jarek Poplawski wrote:
> On 15-06-2009 19:00, Patrick McHardy wrote:
> > This patch contains the final driver ndo_start_xmit() return
> > value fixups. I'm pretty sure I got them all ...

...You should probably revisit wireless/zd1201.c (return 0) btw.

Jarek P.
