From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [patch 5/7] CAN: Add virtual CAN netdevice driver
Date: Wed, 30 May 2007 21:25:42 +0200
Message-ID: <465DCFB6.6090700@hartkopp.net>
References: <20070530131123.10843.0@janus.isnogud.escape.de>	<20070530131204.10843.5@janus.isnogud.escape.de>	<20070530102810.1689119b@freepuppy>	<465DC91D.1030104@hartkopp.net> <20070530120112.63aac6cd@freepuppy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Urs Thuermann <urs@isnogud.escape.de>,
	David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:24928 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753668AbXE3T0A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 15:26:00 -0400
In-Reply-To: <20070530120112.63aac6cd@freepuppy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Wed, 30 May 2007 20:57:33 +0200
> Oliver Hartkopp <oliver@hartkopp.net> wrote:
>
>   
>> Does 'unneeded' belong to always the last line of the quoted code snippet?
>>
>>     
>
> They are all places where you assign zero (or NULL) to something that is
> already initialized to zero by alloc_netdev.
>
>   

ACK! Will be removed.

Thanks,
Oliver

