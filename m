From: David Miller <davem@davemloft.net>
Subject: Re: [patch 0/4] s390: networking patches for 2.6.33
Date: Fri, 13 Nov 2009 20:49:00 -0800 (PST)
Message-ID: <20091113.204900.121349705.davem@davemloft.net>
References: <20091113074626.078348000@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com
To: ursula.braun@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50261
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755238AbZKNEso (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 23:48:44 -0500
In-Reply-To: <20091113074626.078348000@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>
Date: Fri, 13 Nov 2009 08:46:26 +0100

> here is a set of networking patches for 2.6.33.
> 
> shortlog:
> Frank  Blaschka (1)
> ctcm: suspend has to wait for outstanding I/O
> 
> Ursula Braun (3)
> iucv: add work_queue cleanup for suspend
> s390: remove cu3088 layer for lcs and ctcm
> netiucv: displayed TX bytes value much too high

All applied, thanks.
