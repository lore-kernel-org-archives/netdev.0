From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RFC] dependencies for platform drivers (was Re: ax88796: add
 superh to kconfig dependencies)
Date: Fri, 09 Nov 2007 22:12:12 -0500
Message-ID: <4735218C.2000202@garzik.org>
References: <20071108073105.3996.70418.sendpatchset@clockwork.opensource.se> <20071108081854.GN8181@ftp.linux.org.uk> <20071109120648.GA31353@fluff.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Al Viro <viro@ftp.linux.org.uk>,
	Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
	lethal@linux-sh.org, ben-linux@fluff.org,
	akpm@linux-foundation.org, linux-arch@vger.kernel.org
To: Ben Dooks <ben@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38373 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750944AbXKJDMV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Nov 2007 22:12:21 -0500
In-Reply-To: <20071109120648.GA31353@fluff.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Dooks wrote:
> in submission process, or awaiting for an resolution. In the case
> of simtec-ide, I would like to replace it with platform-ata, but
> the libata maintainers seem wholy un-interested in
> PLAT_HAS_PLATFORM_ATA or similar.


I've either missed or forgotten your patch/proposal, want to repost to 
linux-ide?

I want to spread libata to the far corner of the globe, and am quite 
interested in supporting all architectures.

	Jeff


