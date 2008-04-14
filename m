From: David Miller <davem@davemloft.net>
Subject: Re: [TCP 0/6 net-2.6.26]: tcp_proc_register simplification (resend)
Date: Sun, 13 Apr 2008 22:22:40 -0700 (PDT)
Message-ID: <20080413.222240.151427648.davem@davemloft.net>
References: <1207661633.7171.25.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50560
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751849AbYDNFWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 01:22:39 -0400
In-Reply-To: <1207661633.7171.25.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Tue, 08 Apr 2008 17:33:53 +0400

> I have found that tcp_proc_register looks in the same way as
> udp_proc_register. So, I have ported improvements made in the commits
> 6f191efe48af62dd5f8917dd21d187f896cd6c81..4ad96d39a2d74c1b2e400b602da2594f5098fc26
> to TCP.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Applied and pushed out to net-2.6.26, thanks!
