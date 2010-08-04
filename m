From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH ethtool 1/2] ethtool: Use inet_aton() to parse IPv4 addresses
 for RX n-tuple control
Date: Wed, 04 Aug 2010 16:36:53 -0400
Message-ID: <4C59CF65.2060801@garzik.org>
References: <1279825899.2104.28.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:33035 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934801Ab0HDUhW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 16:37:22 -0400
Received: by ywh1 with SMTP id 1so2132664ywh.19
        for <netdev@vger.kernel.org>; Wed, 04 Aug 2010 13:37:22 -0700 (PDT)
In-Reply-To: <1279825899.2104.28.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


FYI, I'm about to roll a new ethtool release for kernel 2.6.35.  Are 
these two patches the only outstanding ones?  (they look good, will be 
applied)

	Jeff



P.S.  The maintainer address is jgarzik@pobox.com, my standard kernel 
address.  jgarzik@redhat.com has a much higher latency, as it doesn't 
get used very much.


