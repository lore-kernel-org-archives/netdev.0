From: David Miller <davem@davemloft.net>
Subject: Re: lockdep: include/linux/lockdep.h - fix warning in
 net/bluetooth/af_bluetooth.c
Date: Thu, 13 Nov 2008 23:21:19 -0800 (PST)
Message-ID: <20081113.232119.121170876.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, netdev@vger.kernel.org
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34759
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750777AbYKNHVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2008 02:21:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I applied Ingo's version of this warning fix to net-2.6, mainly
because his was submitted first :-)

Thanks everyone.
