From: Greg KH <greg@kroah.com>
Subject: Re: 2.6.21-rc1: known regressions (part 3)
Date: Sun, 25 Feb 2007 12:59:42 -0800
Message-ID: <20070225205942.GA26624@kroah.com>
References: <Pine.LNX.4.64.0702202043280.4043@woody.linux-foundation.org> <20070225180251.GD12392@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Albert Hopkins <kernel@marduk.letterboxes.org>,
	Ayaz Abdulla <aabdulla@nvidia.com>, jgarzik@pobox.com,
	netdev@vger.kernel.org, Bob Tracy <rct@gherkin.frus.com>,
	Mark Brown <broonie@sirena.org.uk>,
	YOSHIFUJI Hideaki / ???????????? <yoshfuji@linux-ipv6.org>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Michael-Luke Jones <mlj28@cam.ac.uk>,
	Pete Clements <clem@clem.clem-digital.net>,
	Sid Boyce <g3vbv@blueyonder.co.uk>,
	Chuck Lever <chuck.lever@oracle.com>,
	Andreas Schwab <schwab@suse.de>, Dave Jones <davej@redhat.com>
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:51718 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752426AbXBYVCn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Feb 2007 16:02:43 -0500
Content-Disposition: inline
In-Reply-To: <20070225180251.GD12392@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 25, 2007 at 07:02:51PM +0100, Adrian Bunk wrote:
> 
> 
> Subject    : request_module: runaway loop modprobe net-pf-1
> References : http://lkml.org/lkml/2007/2/21/206
> Submitter  : YOSHIFUJI Hideaki / ???????????? <yoshfuji@linux-ipv6.org>
> Caused-By  : Kay Sievers <kay.sievers@vrfy.org>
>              commit c353c3fb0700a3c17ea2b0237710a184232ccd7f
> Handled-By : Greg KH <greg@kroah.com>
> Status     : problem is being discussed

Patch has been reverted and submitted to Linus to pull, but he's out of
town right now...

thanks,

greg k-h
