From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Convert network devices to use struct device instead
 of class_device
Date: Sat, 17 Feb 2007 15:12:06 -0500
Message-ID: <45D76196.6090708@garzik.org>
References: <Pine.LNX.4.64.0702140036350.855@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47613 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751666AbXBQUMJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Feb 2007 15:12:09 -0500
In-Reply-To: <Pine.LNX.4.64.0702140036350.855@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kumar Gala wrote:
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

pulled


