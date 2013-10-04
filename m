From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH] xen-netback: Don't destroy the netdev until the vif is
 shut
Date: Fri, 4 Oct 2013 14:23:00 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD011ACFE@AMSPEX01CL01.citrite.net>
References: <20131004.002248.789391156050342547.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:46970 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754482Ab3JDOXE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 10:23:04 -0400
In-Reply-To: <20131004.002248.789391156050342547.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: 04 October 2013 05:23
> To: Paul Durrant
> Cc: netdev@vger.kernel.org; Wei Liu
> Subject: Re: [PATCH] xen-netback: Don't destroy the netdev until the vif is
> shut
> 
> 
> Can one of you do -stable backports of this change for v3.11 and any
> other active -stable branch where this fix is relevant?
> 

Ok. Will do.

  Paul

> I gave it a shot, and it got outside my realm of expertise.
> 
> Thanks!
