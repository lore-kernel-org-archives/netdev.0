From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] sky2: netpoll on port 0 only
Date: Thu, 8 Nov 2007 12:47:13 -0500
Message-ID: <20071108174713.GA3011@havoc.gtf.org>
References: <20071106114540.75ec66ab@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:40390 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758717AbXKHRrO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Nov 2007 12:47:14 -0500
Content-Disposition: inline
In-Reply-To: <20071106114540.75ec66ab@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 06, 2007 at 11:45:40AM -0800, Stephen Hemminger wrote:
> Netpoll will only work on port 0 because of the restrictive
> relationship between NAPI and netpoll.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

applied


