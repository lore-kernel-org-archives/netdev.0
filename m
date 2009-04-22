From: David Miller <davem@davemloft.net>
Subject: Re: [patch 0/5] [RESEND] af_iucv patches for 2.6.30-rc1
Date: Tue, 21 Apr 2009 23:46:36 -0700 (PDT)
Message-ID: <20090421.234636.220700386.davem@davemloft.net>
References: <20090421160419.971500000@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com
To: ursula.braun@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37204
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752469AbZDVGqo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 02:46:44 -0400
In-Reply-To: <20090421160419.971500000@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>
Date: Tue, 21 Apr 2009 18:04:19 +0200

> as suggested, here is the series of critical af_iucv bug fixes.
> I will submit the remaining af_iucv patches to net-next-2.6.
> The patches are based on top of the current net-2.6 kernel
> (2.6.30-rc1).
> 
> Hendrik Brueckner (11):
>     af_iucv: fix oops in iucv_sock_recvmsg() for MSG_PEEK flag
>     af_iucv: Reject incoming msgs if RECV_SHUTDOWN is set
>     af_iucv: Test additional sk states in iucv_sock_shutdown
>     af_iucv: Fix race when queuing incoming iucv messages
> 
> Ursula Braun (2):
>     af_iucv: consider state IUCV_CLOSING when closing a socket

All applied, thanks.
