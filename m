From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: sock_bindtodevice() RCU-ification
Date: Fri, 06 Nov 2009 00:17:30 -0800 (PST)
Message-ID: <20091106.001730.184664486.davem@davemloft.net>
References: <20091105.210830.108657873.davem@davemloft.net>
	<20091105.223921.83639611.davem@davemloft.net>
	<4AF3CB8B.2090206@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36261
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753750AbZKFIRF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 03:17:05 -0500
In-Reply-To: <4AF3CB8B.2090206@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 06 Nov 2009 08:08:59 +0100

> Thanks David, which gcc version are you using ?

I'm using "gcc-4.2.4 (Ubuntu 4.2.4-1ubuntu3)" on sparc.



