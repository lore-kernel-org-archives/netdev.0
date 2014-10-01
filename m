From: Eli Cohen <eli@mellanox.com>
Subject: RE: [PATCH net-next 2/4] net/mlx5_core: Use hardware registers
 description header file
Date: Wed, 1 Oct 2014 13:47:41 +0000
Message-ID: <CFE9BFE80FFE4D4892AA5D31387E310F014FC6D3D6@MTLDAG02.mtl.com>
References: <1412082135-30229-4-git-send-email-eli@mellanox.com>
	<20140930153445.GA9303@localhost.westell.com>
	<CFE9BFE80FFE4D4892AA5D31387E310F014FC6C85B@MTLDAG02.mtl.com>
 <20140930.161357.778280234084349300.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>,
	"eli@dev.mellanox.co.il" <eli@dev.mellanox.co.il>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	"Yevgeny Petrilin" <yevgenyp@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog125.obsmtp.com ([207.126.144.159]:34325 "EHLO
	eu1sys200aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750992AbaJANrr convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2014 09:47:47 -0400
In-Reply-To: <20140930.161357.778280234084349300.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>People will try to review it only to discover that it's completely unused.
>
>I've been through this before with other device driver teams telling us that it's part of some automated framework etc. and that >doesn't make it acceptable.
>
>Please trim these things down to exactly what the driver uses.

OK, I have sent a few minutes ago V1 series that fixes that.
