From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] netpoll: fix race on poll_list resulting in garbage
	entry
Date: Thu, 18 Dec 2008 09:47:19 -0500
Message-ID: <20081218144719.GA4348@hmsreliant.think-freely.org>
References: <20081217211628.GD7356@hmsreliant.think-freely.org> <20081217133131.44a4f67f@extreme> <20081218011306.GA32191@hmsreliant.think-freely.org> <20081217.192936.169928910.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, jarkao2@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42663 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751115AbYLROt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 09:49:26 -0500
Content-Disposition: inline
In-Reply-To: <20081217.192936.169928910.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 17, 2008 at 07:29:36PM -0800, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Wed, 17 Dec 2008 20:13:06 -0500
> 
> > Ok, here you go, one omnibus patch
> 
> This doesn't apply to net-next-2.6, not even by a country mile.
> :-)
> 
> Please respin this, thanks.
> 

Apologies, I built this against net-2.6.git, not net-next
I'll rediff and report shortly.
Neil

-- 
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/
