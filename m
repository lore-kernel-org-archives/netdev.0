From: David Miller <davem@davemloft.net>
Subject: Re: WARNING: at net/ipv4/af_inet.c:155
 inet_sock_destruct+0x122/0x13a()
Date: Mon, 03 Aug 2009 21:20:07 -0700 (PDT)
Message-ID: <20090803.212007.253928711.davem@davemloft.net>
References: <4A76A009.40605@wpkg.org>
	<1249346282.6479.5.camel@merlyn>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mangoo@wpkg.org, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: john.dykstra1@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37618
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751508AbZHDET6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 00:19:58 -0400
In-Reply-To: <1249346282.6479.5.camel@merlyn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Dykstra <john.dykstra1@gmail.com>
Date: Mon, 03 Aug 2009 19:38:01 -0500

> There's a good chance e51a67a9c8a2ea5c563f8c2ba6613fe2100ffe67 from the
> current mainline will fix this problem.
> 
> Dave, Eric's fix might be a candidate for -stable.  The symptom is
> usually a WARN, but the impact is significant.

Hmmm, I'll double-check.  I thought I had submitted this one.

Thanks for the heads up.
