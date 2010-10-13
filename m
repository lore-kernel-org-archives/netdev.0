From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 5/5] tipc: clean out all instances of #if 0'd
 unused code
Date: Wed, 13 Oct 2010 12:26:52 -0400
Message-ID: <20101013162652.GF31379@hmsreliant.think-freely.org>
References: <1286929558-2954-1-git-send-email-paul.gortmaker@windriver.com>
 <1286929558-2954-5-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	allan.stephens@windriver.com
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:54885 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750963Ab0JMQ04 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 12:26:56 -0400
Content-Disposition: inline
In-Reply-To: <1286929558-2954-5-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 12, 2010 at 08:25:58PM -0400, Paul Gortmaker wrote:
> Remove all instances of legacy, or as yet to be implemented code
> that is currently living within an #if 0 ... #endif block.
> In the rare instance that some of it be needed in the future,
> it can still be dragged out of history, but there is no need
> for it to sit in mainline.
> 
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>

