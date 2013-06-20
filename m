From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] sh_eth: add NAPI support
Date: Wed, 19 Jun 2013 17:03:46 -0700 (PDT)
Message-ID: <20130619.170346.174389946083590708.davem@davemloft.net>
References: <201306192330.23477.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com,
	linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201306192330.23477.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Wed, 19 Jun 2013 23:30:23 +0400

> The driver hasn't used NAPI so far; implement its support at last...
> 
> The patch was tested on Renesas R8A77781 BOCK-W board.
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Thanks for doing this, applied.
