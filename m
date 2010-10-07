From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool: add the stmmac support
Date: Thu, 07 Oct 2010 14:13:31 +0100
Message-ID: <1286457211.2271.7.camel@achroite.uk.solarflarecom.com>
References: <1285667519-4621-1-git-send-email-peppe.cavallaro@st.com>
	 <4CAC0AE8.2060808@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Peppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:8568 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754100Ab0JGNNe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Oct 2010 09:13:34 -0400
In-Reply-To: <4CAC0AE8.2060808@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-10-06 at 07:36 +0200, Peppe CAVALLARO wrote:
> Hello,
> 
> On 09/28/2010 11:51 AM, Giuseppe CAVALLARO wrote:
> > Add the stmmac support into the ethtool to
> > dump both the Mac Core and Dma registers.
> 
> Any news for this patch?
> 
> The stmmac is now working on several platforms (not only on STM ST40
> based boxes). I think it's worth having the ethtool support for the driver.
> 
> Welcome review and advice as usual.
[...]

You need to send ethtool patches to the ethtool maintainer, Jeff Garzik
<jgarzik@pobox.com>.  I expect he'll make an ethtool release shortly
after Linux 2.6.36, and will apply patches then.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

