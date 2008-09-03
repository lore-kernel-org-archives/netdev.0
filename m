From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [Resend] [PATCH] bonding: change some __constant_htons() to htons()
Date: Wed, 03 Sep 2008 10:09:00 -0400
Message-ID: <48BE9A7C.30707@pobox.com>
References: <48BD48C8.1090806@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43726 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754575AbYICOJF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 10:09:05 -0400
In-Reply-To: <48BD48C8.1090806@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Haley wrote:
> Resending since I didn't see any responses from the first try.
> 
> Change __constant_htons() to htons() in the bonding driver, it should
> only be used for initializers.
> 
> -Brian
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>

applied


