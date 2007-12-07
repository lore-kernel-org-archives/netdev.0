From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.24 1/1]S2io: Check for register initialization completion
 before accesing device registers
Date: Fri, 07 Dec 2007 15:09:32 -0500
Message-ID: <4759A87C.6030101@garzik.org>
References: <Pine.GSO.4.10.10712052356570.27705-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57757 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756405AbXLGUJg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Dec 2007 15:09:36 -0500
In-Reply-To: <Pine.GSO.4.10.10712052356570.27705-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sreenivasa Honnur wrote:
> - Making sure register initialisation is complete before proceeding further.
>   The driver must wait until initialization is complete before attempting to 
>   access any other device registers.
> 
> Signed-off-by: Surjit Reang <surjit.reang@neterion.com>
> Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>

applied #upstream-fixes


