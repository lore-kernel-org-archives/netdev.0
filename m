From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] tcp: Fix MD5 signature checking on IPv4 mapped
 sockets
Date: Mon, 20 Jul 2009 07:50:20 -0700 (PDT)
Message-ID: <20090720.075020.61425436.davem@davemloft.net>
References: <1247756691.7627.5.camel@Maple>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: john.dykstra1@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56648
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751108AbZGTOuP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2009 10:50:15 -0400
In-Reply-To: <1247756691.7627.5.camel@Maple>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Dykstra <john.dykstra1@gmail.com>
Date: Thu, 16 Jul 2009 10:04:51 -0500

> Fix MD5 signature checking so that an IPv4 active open
> to an IPv6 socket can succeed.  In particular, use the
> correct address family's signature generation function
> for the SYN/ACK.
> 
> Reported-by:   Stephen Hemminger <shemminger@vyatta.com>
> Signed-off-by: John Dykstra <john.dykstra1@gmail.com>

Applied.
