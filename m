From: Neil Jerram <Neil.Jerram@metaswitch.com>
Subject: RE: [PATCH 07/12] vti: Update the ipv4 side to use it's own receive
 hook.
Date: Thu, 27 Feb 2014 10:42:35 +0000
Message-ID: <F6885DC5CBE92C4BB4D654841E63A30FD7DD9CB6@ENFIRHMBX1.datcon.co.uk>
References: <1393488040-22005-1-git-send-email-steffen.klassert@secunet.com>
 <1393488040-22005-8-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Steffen Klassert' <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from enfirhets1.metaswitch.com ([192.91.191.166]:9293 "EHLO
	ENFIRHETS1.metaswitch.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993AbaB0Kml convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 05:42:41 -0500
In-Reply-To: <1393488040-22005-8-git-send-email-steffen.klassert@secunet.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Subject: [PATCH 07/12] vti: Update the ipv4 side to use it's own receive hook.
> 
> With this patch, vti uses the IPsec protocol multiplexer to
> register it's own receive side hooks for ESP, AH and IPCOMP.

FYI, "it's" here should be "its" (both times).

Apologies in advance if this kind of spelling review comment is inappropriate or bad etiquette here - if that's the case, please just say, and I won't do it again!

Regards,
     Neil
