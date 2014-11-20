From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net] net/mlx4_en: Add VXLAN ndo calls to the PF net device
 ops too
Date: Thu, 20 Nov 2014 07:16:03 +0200
Message-ID: <546D7913.7040508@mellanox.com>
References: <1416325887-14704-1-git-send-email-ogerlitz@mellanox.com> <20141119.151155.2119587385505880097.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <fw@strlen.de>, <amirv@mellanox.com>,
	<saeedm@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:53568 "EHLO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750838AbaKTFRY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 00:17:24 -0500
In-Reply-To: <20141119.151155.2119587385505880097.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/19/2014 10:11 PM, David Miller wrote:
> Applied, -stable material? If so for what releases? In the future, if 
> you add an appropriated Fixes: tag I can figure most of this out 
> without asking you. Thanks. 


Yes, please! let the below commits two swim for a while in 3.18-rc and 
later push
them to -stable >= 3.15, got it re the fixes: tag, thanks for the heads-up.

9737c6a net/mlx4_en: Add VXLAN ndo calls to the PF net device ops too
f4a1edd net/mlx4_en: Advertize encapsulation offloads features only when 
VXLAN tunnel is set

Or.
