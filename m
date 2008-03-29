From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2/2 v2] pasemi_mac: Netpoll support
Date: Fri, 28 Mar 2008 22:11:21 -0400
Message-ID: <47EDA549.3030806@pobox.com>
References: <20080326015625.GA23103@lixom.net> <20080326015801.GC23103@lixom.net> <20080327224007.GB17980@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, pasemi-linux@ozlabs.org,
	netdev@vger.kernel.org, ncase@xes-inc.com
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38122 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753694AbYC2CLZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 22:11:25 -0400
In-Reply-To: <20080327224007.GB17980@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Olof Johansson wrote:
> Add netpoll support to allow use of netconsole.
>     
> Signed-off-by: Nate Case <ncase@xes-inc.com>
> Signed-off-by: Olof Johansson <olof@lixom.net>
> 
> ---
> Changed the interrupt handler arguments as found by Valentine. Will push
> through powerpc.git with Jeff's ACKs (that were already given).
> 
> 
> -Olof

ACK


