From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Convert network devices to use struct device instead of class_device
Date: Wed, 14 Feb 2007 14:40:59 -0500
Message-ID: <20070214194059.GB30071@havoc.gtf.org>
References: <Pine.LNX.4.64.0702140036350.855@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:50988 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751164AbXBNTlB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Feb 2007 14:41:01 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0702140036350.855@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 14, 2007 at 12:40:00AM -0600, Kumar Gala wrote:
> Convert network devices to use struct device instead of class_device.  Greg
> missed this one in his cleanup path.
> 
> Signed-off-by: Kumar Gala <galak@kernel.crashing.org>
> 
> ---
> 
> Jeff,
> 
> Sorry my mailer was completely screwed.  I thought I had fixed the
> settings to turn of flowed text.  I think this was why the patches I've
> been sending haven't been applying.  You can also get this fix from the
> following git tree:
> 
> master.kernel.org/pub/scm/linux/kernel/git/galak/powerpc.git gfar

I will probably pull it, but I've away at a fs/storage conference so
things are backed up this week.

	Jeff



