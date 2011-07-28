From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: Re: invalid requirement from ethtool?
Date: Thu, 28 Jul 2011 17:55:56 +0300
Message-ID: <20110728145556.GD6750@mtldesk30>
References: <20110726124222.GA4842@mtldesk30>
 <20110727.224309.779719590419361909.davem@davemloft.net>
 <20110728072326.GC6750@mtldesk30>
 <20110728.003758.292509567308751079.davem@davemloft.net>
 <1311848553.2619.1.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:55011 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751676Ab1G1O4C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 10:56:02 -0400
Received: by wwg11 with SMTP id 11so4080900wwg.1
        for <netdev@vger.kernel.org>; Thu, 28 Jul 2011 07:56:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1311848553.2619.1.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 28, 2011 at 12:22:33PM +0200, Ben Hutchings wrote:
> 
> The ethtool core doesn't check the values in struct ethtool_coalesce, so
> the rules are really driver-specific.
> 

Exactly. That's why I think those comments are not in place.
