From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] sh_eth: remove 'tx_error_check' field of 'struct
 sh_eth_cpu_data'
Date: Wed, 19 Jun 2013 17:03:51 -0700 (PDT)
Message-ID: <20130619.170351.1940958966309807340.davem@davemloft.net>
References: <201306200222.56406.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com,
	linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201306200222.56406.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Thu, 20 Jun 2013 02:22:56 +0400

> The 'tx_error_check' field of 'struct sh_eth_cpu_data' is write-only, so remove
> it along with the DEFAULT_TX_ERROR_CHECK macro.
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied.
