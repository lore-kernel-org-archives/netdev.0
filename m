From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 4/7] remove the broken SKMC driver
Date: Tue, 26 Dec 2006 16:42:15 -0500
Message-ID: <45919737.5000506@garzik.org>
References: <200612192108.kBJL8m4D010498@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bunk@stusta.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41574 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932808AbWLZVmR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Dec 2006 16:42:17 -0500
To: akpm@osdl.org
In-Reply-To: <200612192108.kBJL8m4D010498@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@osdl.org wrote:
> From: Adrian Bunk <bunk@stusta.de>
> 
> The SKMC driver has:
> - already been marked as BROKEN in 2.6.0 three years ago and
> - is still marked as BROKEN.
> 
> Drivers that had been marked as BROKEN for such a long time seem to be
> unlikely to be revived in the forseeable future.
> 
> But if anyone wants to ever revive this driver, the code is still
> present in the older kernel releases.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

applied


