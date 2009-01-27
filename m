From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add tracepoints to socket api
Date: Mon, 26 Jan 2009 17:22:53 -0800 (PST)
Message-ID: <20090126.172253.25010769.davem@davemloft.net>
References: <20090126195930.GA28208@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45477
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751688AbZA0BWz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 20:22:55 -0500
In-Reply-To: <20090126195930.GA28208@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon, 26 Jan 2009 14:59:30 -0500

> @@ -95,6 +95,7 @@
>  
>  #include <net/sock.h>
>  #include <linux/netfilter.h>
> +#include <trace/socket.h>

Where is this mysterious include/trace/socket.h file?
I can't seem to find it :-)
