From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 1/2] atm: Use ARRAY_SIZE macro when appropriate
Date: Sat, 17 Feb 2007 15:31:48 -0500
Message-ID: <45D76634.5020202@garzik.org>
References: <200702160942.l1G9gNPY026487@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, darwish.07@gmail.com,
	chas@cmf.nrl.navy.mil
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47821 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932723AbXBQUbz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Feb 2007 15:31:55 -0500
In-Reply-To: <200702160942.l1G9gNPY026487@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: "Ahmed S. Darwish" <darwish.07@gmail.com>
> 
> Use ARRAY_SIZE macro already defined in kernel.h for ATM
> drivers.
> 
> Signed-off-by: Ahmed S. Darwish <darwish.07@gmail.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: chas williams <chas@cmf.nrl.navy.mil>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/atm/he.c         |    2 +-
>  drivers/atm/idt77252.c   |    8 ++++----
>  drivers/atm/nicstarmac.c |    4 +++-
>  3 files changed, 8 insertions(+), 6 deletions(-)

applied


