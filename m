From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] sh_eth: remove redundant bits from 'eesipr_value'
 field initializer
Date: Wed, 19 Jun 2013 17:03:57 -0700 (PDT)
Message-ID: <20130619.170357.2163822839529778655.davem@davemloft.net>
References: <201306200224.54487.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com,
	linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201306200224.54487.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Thu, 20 Jun 2013 02:24:54 +0400

> For SH7724 'eesipr_value' field initializer includes DMAC_M_RFRMER & DMAC_M_ECI
> bits which are already contained in 0x01ff009f -- remove them.
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied.
