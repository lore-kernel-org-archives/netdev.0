From: David Miller <davem@davemloft.net>
Subject: Re: [patch] bridge: br_dump_ifinfo index fix
Date: Mon, 03 Jul 2006 19:50:26 -0700 (PDT)
Message-ID: <20060703.195026.116349701.davem@davemloft.net>
References: <20060703160640.A15611@castle.nmd.msu.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvz.org, greearb@candelatech.com,
	shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:52878
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750735AbWGDCuM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jul 2006 22:50:12 -0400
To: saw@swsoft.com
In-Reply-To: <20060703160640.A15611@castle.nmd.msu.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrey Savochkin <saw@swsoft.com>
Date: Mon, 3 Jul 2006 16:06:40 +0400

> Fix for inability of br_dump_ifinfo to handle non-zero start index:
> loop index never increases when entered with non-zero start.
> Spotted by Kirill Korotaev.
> 
> Signed-off-by: Andrey Savochkin <saw@swsoft.com>
> Cc: Kirill Korotaev <dev@openvz.org>

Applied, thanks Andrey.
