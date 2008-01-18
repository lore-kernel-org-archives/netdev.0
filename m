From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [Patch 2.6.24 1/1]S2io: Fixed synchronization between scheduling
 of napi with card reset and close
Date: Fri, 18 Jan 2008 14:42:00 -0500
Message-ID: <47910108.2060304@garzik.org>
References: <Pine.GSO.4.10.10801142021110.20238-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52286 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758414AbYARTmE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2008 14:42:04 -0500
In-Reply-To: <Pine.GSO.4.10.10801142021110.20238-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sreenivasa Honnur wrote:
> - Fixed synchronization between scheduling of napi with card reset and close 
>   by moving the enabling and disabling of napi to card up and card down 
>   functions respectively instead of open and close.
> 
> Signed-off-by: Surjit Reang <surjit.reang@neterion.com>
> Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>

applied


