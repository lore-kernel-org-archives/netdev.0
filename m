From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [2.6 patch] make netxen_workq static
Date: Sat, 12 Apr 2008 05:02:50 -0400
Message-ID: <48007ABA.7030705@pobox.com>
References: <20080330232218.GP28445@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dhananjay Phadke <dhananjay@netxen.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59425 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756971AbYDLJCy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Apr 2008 05:02:54 -0400
In-Reply-To: <20080330232218.GP28445@cs181133002.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adrian Bunk wrote:
> netxen_workq can now become static.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>
> 
> ---
> 
>  drivers/net/netxen/netxen_nic.h      |   17 -----------------
>  drivers/net/netxen/netxen_nic_main.c |   20 +++++++++++++++++++-
>  2 files changed, 19 insertions(+), 18 deletions(-)

applied this and the other netxen cleanup


