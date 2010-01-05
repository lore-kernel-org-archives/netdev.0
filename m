From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH RFC] r8169: straighten out overlength frame detection (v3)
Date: Tue, 5 Jan 2010 17:04:53 -0500
Message-ID: <20100105220452.GB6825@localhost.localdomain>
References: <4B4357A9.5010507@gmail.com>
 <20100105.124040.192660261.davem@davemloft.net>
 <20100105213856.GB24245@hmsreliant.think-freely.org>
 <20100105.134537.244111255.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	romieu@fr.zoreil.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42881 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754953Ab0AEWE4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 17:04:56 -0500
Content-Disposition: inline
In-Reply-To: <20100105.134537.244111255.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 05, 2010 at 01:45:37PM -0800, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Tue, 5 Jan 2010 16:38:56 -0500
> 
> > I think thats what I've done in my third version of the patch here.
> > By raising the copybreak value, and setting an initial allocation
> > size of 16k, we:
> 
> Right, I'll take an even closer look at your patch later this
> afternoon, thanks Neil.
> 
No problem, thank you Dave!
Neil

