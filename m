From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] AF_PACKET: Add documentation for queue mapping fanout
 mode
Date: Mon, 27 Jan 2014 21:15:37 -0500
Message-ID: <20140128021537.GA24554@neilslaptop.think-freely.org>
References: <1390840984-22246-1-git-send-email-nhorman@tuxdriver.com>
 <87d2jdqepa.fsf@tassilo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42237 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751425AbaA1CQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jan 2014 21:16:07 -0500
Content-Disposition: inline
In-Reply-To: <87d2jdqepa.fsf@tassilo.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 27, 2014 at 01:48:01PM -0800, Andi Kleen wrote:
> Neil Horman <nhorman@tuxdriver.com> writes:
> 
> > Recently I added a new AF_PACKET fanout operation mode in commit
> > 2d36097, but I forgot to document it.  Add PACKET_FANOUT_QM as an available mode
> > in the af_packet documentation.  Applies to net-next.
> 
> Please also send a man page patch.
> 
> -Andi
> 
I'll take care of it in the am.  Thanks for the reminder!
Neil

> -- 
> ak@linux.intel.com -- Speaking for myself only
> 
