From: Jeff Garzik <jeff@garzik.org>
Subject: Re: on the topic of alternate MAC addresses
Date: Tue, 23 Oct 2007 22:30:53 -0400
Message-ID: <471EAE5D.3050808@garzik.org>
References: <20071023.180534.59659315.davem@davemloft.net> <471EAD01.5030502@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46224 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751944AbXJXCaz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2007 22:30:55 -0400
In-Reply-To: <471EAD01.5030502@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> hmmmm.  Using ethtool isn't a big deal, but IMO you probably want more 
> than just an exported list for the usage you described...  it sounds 
> like some sort of reservation system should be used, to note which MAC 
> addresses are [not] in use?
> 
> Then a virt client -- or anyone who wants multiple unicast addresses for 
> whatever reason -- can let other clients to avoid MAC addresses 1, 7, or 
> 13 (random examples).

er, "can let other clients know to"....


