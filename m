From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [GIT *] Solos PCI ADSL card update
Date: Tue, 17 Mar 2009 13:41:22 -0700
Message-ID: <20090317134122.4da1b853@nehalam>
References: <1237310370.27681.314.camel@macbook.infradead.org>
	<20090317.122317.150954865.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dwmw2@infradead.org, netdev@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net, chas@cmf.nrl.navy.mil
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33386 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752821AbZCQUla (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Mar 2009 16:41:30 -0400
In-Reply-To: <20090317.122317.150954865.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Mar 2009 12:23:17 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: David Woodhouse <dwmw2@infradead.org>
> Date: Tue, 17 Mar 2009 17:19:30 +0000
> 
> > Please pull from git://git.infradead.org/~dwmw2/solos-2.6.git
> > 
> > This contains a bunch of updates to the Solos PCI driver (full patch
> > below for review):
> 
> So if I don't like patch 3 and want to discuss it as a unit,
> what do I do?  Pull the patch out of your GIT repo and
> start a thread to discuss it?
> 
> Come on, post the whole series, please. :-/
> 
> Nobody can review this huge hunk of intertwines changes.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

I regret ever adding sysfs for network devices when it gets used
for configuration interfaces like this mess.
