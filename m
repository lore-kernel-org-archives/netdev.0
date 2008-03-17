From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] 2.6.25-rc4 de_stop_rxtx polling wrong
Date: Mon, 17 Mar 2008 08:13:19 -0400
Message-ID: <47DE605F.1060100@garzik.org>
References: <20080309013316.GD25083@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: Grant Grundler <grundler@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52381 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752142AbYCQMNV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2008 08:13:21 -0400
In-Reply-To: <20080309013316.GD25083@colo.lackof.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Grant Grundler wrote:
> Jeff,
> This untested patch _should_ fix:
> 	"(net de2104x) Kernel panic with de2104x tulip driver on boot"	
> 	http://bugzilla.kernel.org/show_bug.cgi?id=3156
> 
> But the bug submitter isn't responding.  Same fix has been applied
> to tulip.c (several years ago) and uli526x.c (Feb 2008) drivers.
> 
> Patch was originally against 2.6.23 but applies clean against 2.6.25-rc4.
> 
> [ The panic reported in the bug report was removed in a recently
>   (march 2008) accepted patch from Ondrej Zary. ]
> 
> 
> Signed-off-by: Grant Grundler <grundler@parisc-linux.org>

applied

Please include comments like "Jeff," and "Patch was originally[...]" 
after the "---" separator, so that the automated tools may omit these 
comments without human intervention.


