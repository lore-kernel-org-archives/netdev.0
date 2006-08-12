From: Jeff Garzik <jeff@garzik.org>
Subject: Re: 2.6.18-rc3-mm2 (+ hotfixes): GPF related to skge on suspend
Date: Sat, 12 Aug 2006 09:39:59 -0400
Message-ID: <44DDDA2F.4080404@garzik.org>
References: <200608121207.42268.rjw@sisk.pl> <20060812052853.f9e5d648.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	LKML <linux-kernel@vger.kernel.org>,
	Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45502 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932513AbWHLNkG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Aug 2006 09:40:06 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060812052853.f9e5d648.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> It would be good if you could poke around in gdb, work out exactly which
> statement it's oopsing at, please.

I'm also interested to know if the problem goes away when you disable 
preempt...

	Jeff


