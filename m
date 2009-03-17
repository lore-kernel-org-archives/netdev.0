From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [GIT *] Solos PCI ADSL card update
Date: Tue, 17 Mar 2009 21:36:35 +0000
Message-ID: <1237325795.27681.368.camel@macbook.infradead.org>
References: <1237310370.27681.314.camel@macbook.infradead.org>
	 <20090317.122317.150954865.davem@davemloft.net>
	 <20090317134122.4da1b853@nehalam>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net, chas@cmf.nrl.navy.mil
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:33292 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752426AbZCQVgl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 17:36:41 -0400
In-Reply-To: <20090317134122.4da1b853@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-03-17 at 13:41 -0700, Stephen Hemminger wrote:
> I regret ever adding sysfs for network devices when it gets used
> for configuration interfaces like this mess.

Yeah, I wasn't massively keen on that either.

You didn't speak up a while back when I asked for opinions on how best
to handle this. Feel free to do so now... 

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

