From: David Miller <davem@davemloft.net>
Subject: Re: ipv6 problem with 6lowpan
Date: Thu, 05 Jul 2012 14:22:47 -0700 (PDT)
Message-ID: <20120705.142247.106300452688436771.davem@davemloft.net>
References: <CAJmB2rD8U1ihy4Ai6y5QGjj4f7txDabszesrNrQ=pgEbscePqQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59252 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751191Ab2GEVWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 17:22:48 -0400
In-Reply-To: <CAJmB2rD8U1ihy4Ai6y5QGjj4f7txDabszesrNrQ=pgEbscePqQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Should be fixed by Steffen Kassert's patch which I just pushed into net-next
