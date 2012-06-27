From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHv1] net: added support for 40GbE link.
Date: Wed, 27 Jun 2012 17:03:00 +0100
Message-ID: <1340812980.2591.0.camel@bwh-desktop.uk.solarflarecom.com>
References: <054018eb-a85c-4401-a010-7479aa38d2ef@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Parav Pandit <parav.pandit@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:54209 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752289Ab2F0QDH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 12:03:07 -0400
In-Reply-To: <054018eb-a85c-4401-a010-7479aa38d2ef@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-27 at 19:26 +0530, Parav Pandit wrote:
> 1. removed code replication for tov calculation for 1G, 10G and
> made is common for speed > 1G (1G, 10G, 40G, 100G).
> 2. defines values for #4 different 40G Phys (KR4, LF4, SR4, CR4)
> 
> Signed-off-by: Parav Pandit <parav.pandit@emulex.com>
Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
