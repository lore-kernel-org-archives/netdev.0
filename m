From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [NET] meth driver renovation
Date: Thu, 24 May 2007 17:21:32 -0400
Message-ID: <465601DC.80908@garzik.org>
References: <20070524115404.GC27073@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	linux-mips@linux-mips.org,
	Shane McDonald <Shane_McDonald@pmc-sierra.com>
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48044 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753328AbXEXVVm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 May 2007 17:21:42 -0400
In-Reply-To: <20070524115404.GC27073@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ralf Baechle wrote:
> The meth ethernet driver for the SGI IP32 aka O2 is so far still an old
> style driver which does not use the device driver model.  This is now
> causing issues with some udev based gadgetry in debian-stable.  Fixed by
> converting the meth driver to a platform device.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
> 
> --
> Fixes since previous patch:
> 
>   o Fixed typo in meth_exit_module()

applied


