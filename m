From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] decnet: netdevice refcount leak
Date: Fri, 06 Nov 2009 01:07:53 -0800 (PST)
Message-ID: <20091106.010753.159888500.davem@davemloft.net>
References: <4AF3E1B3.8070204@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60938
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752887AbZKFJH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 04:07:27 -0500
In-Reply-To: <4AF3E1B3.8070204@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 06 Nov 2009 09:43:31 +0100

> David, if you accept the following patch for net-2.6, it would help me
> if you also can pull it in net-next-2.6

Applied to net-2.6, and net-2.6 is now merged into net-next-2.6,
thanks.
