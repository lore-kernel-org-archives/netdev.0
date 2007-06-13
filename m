From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH]is_power_of_2-myri10ge/myri10ge.c
Date: Wed, 13 Jun 2007 16:17:20 -0400
Message-ID: <467050D0.6090600@garzik.org>
References: <1181624462.3109.22.camel@merlin.linuxcoe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	Kernel Janitors List <kernel-janitors@lists.osdl.org>
To: vignesh.babu@wipro.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39355 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752334AbXFMUR0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2007 16:17:26 -0400
In-Reply-To: <1181624462.3109.22.camel@merlin.linuxcoe.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

vignesh babu wrote:
> Replacing (n & (n-1)) in the context of power of 2 checks
> with is_power_of_2
> 
> Signed-off-by: vignesh babu <vignesh.babu@wipro.com>

Patches look OK, but please

* CC relevant driver maintainers, and
* combined all drivers/net/* patches of this nature into a single patch


