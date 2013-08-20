From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH net-next v4] net: cpsw: Add support for wake-on-lan for
 cpsw
Date: Tue, 20 Aug 2013 11:49:47 +0530
Message-ID: <52130A83.80707@ti.com>
References: <1376978378-26096-1-git-send-email-ujhelyi.m@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: <ujhelyi.m@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:39398 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752316Ab3HTGTv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Aug 2013 02:19:51 -0400
In-Reply-To: <1376978378-26096-1-git-send-email-ujhelyi.m@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 20 August 2013 11:29 AM, ujhelyi.m@gmail.com wrote:
> From: Matus Ujhelyi <ujhelyi.m@gmail.com>
>
> Some phy's can be configured to enable wake on lan (e.g. at803x or marvell 88E1318S).
> There is no way how to enable wol on CPSW with such connected phys. This patch
> adds this support. It is provided by calling the phy's related code.
>
> Tested on board with at8030x connected phy. Wol interrupt line is
> connected to GPIO0 on am335x.
>
> Signed-off-by: Matus Ujhelyi <ujhelyi.m@gmail.com>
> ---
Looks good to me.

Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Also feel free to add my ack in case if you are submitting one more version.

Regards
Mugunthan V N
