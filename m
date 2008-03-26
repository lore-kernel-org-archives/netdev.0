From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH][IBMVETH]: Use single_open instead of manual manipulations.
Date: Wed, 26 Mar 2008 00:36:48 -0400
Message-ID: <47E9D2E0.6020200@garzik.org>
References: <47B9640E.8000701@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Brian King <brking@linux.vnet.ibm.com>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34261 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756112AbYCZEgv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2008 00:36:51 -0400
In-Reply-To: <47B9640E.8000701@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
> The code opening proc entry for each device makes the
> same thing, as the single_open does, so remove the
> unneeded code.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> ---

applied


