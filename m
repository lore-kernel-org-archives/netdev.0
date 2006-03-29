From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Janitor: drivers/net/pcnet32: fix incorrect comments
Date: Wed, 29 Mar 2006 17:35:14 -0500
Message-ID: <442B0BA2.9020200@garzik.org>
References: <20060328223623.GD2172@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tsbogend@alpha.franken.de, donf@us.ibm.com, jklewis@us.bm.com,
	linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751072AbWC2Wfc@vger.kernel.org>
To: Linas Vepstas <linas@austin.ibm.com>
In-Reply-To: <20060328223623.GD2172@austin.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linas Vepstas wrote:
> Please sign-off/ack/apply and/or forward upstream.
> 
> [PATCH] Janitor: drivers/net/pcnet32: fix incorrect comments
> 
> The comments concerning how the pcnet32 ethernet device driver selects 
> the MAC addr to use are incorrect. A recent patch (in the last 3 months)
> changed how the code worked, but did not change the comments.
> 
> Side comment: the new behaviour is good; I've got a pcnet32 card which
> powers up with garbage in the CSR's, and a good MAC addr in the PROM.
> 
> Signed-off-by: Linas Vepstas <linas@linas.org>

applied
