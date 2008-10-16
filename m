From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/2] enic: Fix Kconfig headline description
Date: Thu, 16 Oct 2008 05:30:42 -0400
Message-ID: <48F709C2.6000303@garzik.org>
References: <adaej2kp701.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: scofeldm@cisco.com, netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60229 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751132AbYJPJar (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Oct 2008 05:30:47 -0400
In-Reply-To: <adaej2kp701.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roland Dreier wrote:
> From: Scott Feldman <scofeldm@cisco.com>
> 
> I don't think the enic driver has anything to do with Mark Everett
> (http://en.wikipedia.org/wiki/A_Man_Called_E).  Fix the Kconfig
> description.
> 
> Signed-off-by: Roland Dreier <rolandd@cisco.com>
> ---
> And this is the other half of
> https://kerneltrap.org/mailarchive/linux-netdev/2008/9/20/3350614/thread
> that seems to have gotten dropped.  Please apply.
> 
>  drivers/net/Kconfig |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index e9d5294..1d8af33 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -2400,7 +2400,7 @@ config EHEA
>  	  will be called ehea.
>  
>  config ENIC
> -	tristate "E, the Cisco 10G Ethernet NIC"
> +	tristate "Cisco 10G Ethernet NIC support"
>  	depends on PCI && INET

Sheesh, Cisco just does not have any sense of humor :)

As I explained to Scott (in private email, unfortunately, IIRC), I did 
that so that it would fit in the list alphabetized -- Scott placed it in 
the section with the E's, not the C's.

Furthermore, "Cisco 10G ethernet nic" is a vague description if Cisco 
ever plans to sell another ethernet product.  Will the next one be 
"Cisco 10G Ethernet NIC, the sequel"?  :)

If you insist on such an incredibly boring description, at least put it 
into the section with the 'C' not the 'E'.

	Jeff




