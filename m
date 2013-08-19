From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCHv2] net: cpsw: Add support for wake-on-lan for cpsw
Date: Mon, 19 Aug 2013 17:09:19 +0530
Message-ID: <521203E7.8000502@ti.com>
References: <1376910358-19882-1-git-send-email-ujhelyi.m@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: <ujhelyi.m@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1376910358-19882-1-git-send-email-ujhelyi.m@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 19 August 2013 04:35 PM, ujhelyi.m@gmail.com wrote:
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
Looks good to me.
Acked-by: Mugunthan V N <mugunthanvnm@gmail.com>

Regards
Mugunthan V N
