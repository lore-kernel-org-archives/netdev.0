From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next 4/4] net/mlx4_core: Make sure there are no pending
 async events when freeing CQ
Date: Sun, 31 May 2015 09:30:29 +0300
Message-ID: <556AAA85.8090709@mellanox.com>
References: <1432827676-5599-1-git-send-email-ogerlitz@mellanox.com>
	<1432827676-5599-5-git-send-email-ogerlitz@mellanox.com>
 <20150530.232345.188813752279467836.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <matanb@mellanox.com>,
	<amirv@mellanox.com>, <talal@mellanox.com>, <idos@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0064.outbound.protection.outlook.com ([157.56.112.64]:27456
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757935AbbEaGbN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 May 2015 02:31:13 -0400
In-Reply-To: <20150530.232345.188813752279467836.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/31/2015 9:23 AM, David Miller wrote:
> I agree with Sergei that one empty line is sufficient here, don't make
> it into two.
>
> Please respin with this fixed.

Sure, I prepared V1 to address that earlier today, and will send it now.

Or.
