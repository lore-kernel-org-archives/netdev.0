From: David Miller <davem@davemloft.net>
Subject: Re: [patch 0/7] s390: iucv / af_iucv fixes for 2.6.31+
Date: Wed, 16 Sep 2009 20:58:03 -0700 (PDT)
Message-ID: <20090916.205803.120599769.davem@davemloft.net>
References: <20090916143721.863799000@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com
To: ursula.braun@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34976
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760656AbZIQD5q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2009 23:57:46 -0400
In-Reply-To: <20090916143721.863799000@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>
Date: Wed, 16 Sep 2009 16:37:21 +0200

> Summary:
> 
> Ursula Braun (1)
> iucv: suspend/resume error msg for left over pathes
> 
> Hendrik Brueckner (6)
> iucv: fix iucv_buffer_cpumask check when calling IUCV functions
> iucv: use correct output register in iucv_query_maxconn()
> af_iucv: fix race in __iucv_sock_wait()
> af_iucv: handle non-accepted sockets after resuming from suspend
> af_iucv: do not call iucv_sock_kill() twice
> af_iucv: fix race when queueing skbs on the backlog queue

All applied, thank you.
