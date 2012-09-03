From: Yevgeny Petrilin <yevgenyp@mellanox.com>
Subject: RE: Possible issue with Mellanox mlx4/port handling
Date: Mon, 3 Sep 2012 17:51:25 +0000
Message-ID: <953B660C027164448AE903364AC447D28720CFEB@MTLDAG01.mtl.com>
References: <953B660C027164448AE903364AC447D28720CF7D@MTLDAG01.mtl.com>
 <5044ECA9.5080100@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "mleitner@redhat.com" <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:38372 "HELO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750785Ab2ICRyy convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Sep 2012 13:54:54 -0400
In-Reply-To: <5044ECA9.5080100@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> If you can share, what can we expect it to be like? Like the chunk I suggested
> above or is there anything else needed? I could notice only 6 places calling
> get_promisc_qp() that way and couldn't find any other issue like that.
> 

The fix is pretty much the same style like what you suggested.

Yevgeny
