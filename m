From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 1/2] Remove netpoll blocking from uninit path
Date: Wed, 20 Oct 2010 06:51:30 -0400
Message-ID: <20101020105130.GA14407@hmsreliant.think-freely.org>
References: <1287507866-25156-1-git-send-email-nhorman@tuxdriver.com>
 <1287507866-25156-2-git-send-email-nhorman@tuxdriver.com>
 <4CBE9E7F.60107@redhat.com>
 <20101020.014538.193720733.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: amwang@redhat.com, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, fubar@us.ibm.com,
	andy@greyhouse.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38319 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751803Ab0JTKvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Oct 2010 06:51:45 -0400
Content-Disposition: inline
In-Reply-To: <20101020.014538.193720733.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 20, 2010 at 01:45:38AM -0700, David Miller wrote:
> From: Cong Wang <amwang@redhat.com>
> Date: Wed, 20 Oct 2010 15:47:11 +0800
> 
> > On 10/20/10 01:04, nhorman@tuxdriver.com wrote:
> >> From: Neil Horman<nhorman@tuxdriver.com>
> >>
> >> Some recent testing in netpoll with bonding showed this backtrace
> ...
> >> Signed-off-by: Neil Horman<nhorman@tuxdriver.com>
> > 
> > Reviewed-by: WANG Cong <amwang@redhat.com>
> 
> Applied.
> 
> Neil, please add proper subsystem prefixes to your subject
> lines, I've had to add them by hand as I add your patches.
> 
Copy that, apologies.

Thanks!
Neil

> Thanks.
> 
