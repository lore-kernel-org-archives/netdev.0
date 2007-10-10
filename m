From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH net-2.6.24] chelsio: sparse warning fixes (old cxgb2)
Date: Tue, 09 Oct 2007 20:39:39 -0400
Message-ID: <470C1F4B.1040105@pobox.com>
References: <20071008161910.639c5718@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Divy Le Ray <divy@chelsio.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39090 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753620AbXJJAjn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2007 20:39:43 -0400
In-Reply-To: <20071008161910.639c5718@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Fix problems detected by sparse:
> 1. whole chunk of MAC code was for defined and never used
> 2. hook for running ext intr in workqueue wasn't being used
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 

applied


