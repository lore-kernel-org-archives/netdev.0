From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Request for help with iproute2 bugs.
Date: Tue, 1 Dec 2009 16:20:39 -0800
Message-ID: <20091201162039.4b3388b4@nehalam>
References: <20091123103742.GA14713@amd64.fatal.se>
	<4B0A6C0D.9030402@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andreas Henriksson <andreas@fatal.se>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44030 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754836AbZLBAUi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Dec 2009 19:20:38 -0500
In-Reply-To: <4B0A6C0D.9030402@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Nov 2009 12:03:41 +0100
Patrick McHardy <kaber@trash.net> wrote:

> Andreas Henriksson wrote:
> > http://bugs.debian.org/532727
> >   iproute: "tc filter add ... protocol ip fw" broken?
> > 
> 
> This one is caused by a regression in iproute2. The attached patch
> should fix it.

applied


-- 
