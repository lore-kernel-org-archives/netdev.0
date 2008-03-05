From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH][IBMVETH]: Use single_open instead of manual manipulations.
Date: Wed, 05 Mar 2008 06:16:04 -0500
Message-ID: <47CE80F4.60901@garzik.org>
References: <47B9640E.8000701@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Brian King <brking@linux.vnet.ibm.com>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34451 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751794AbYCELQI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2008 06:16:08 -0500
In-Reply-To: <47B9640E.8000701@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
> The code opening proc entry for each device makes the
> same thing, as the single_open does, so remove the
> unneeded code.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

ACK from ibmveth maintainer?


