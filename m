From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] sh_eth: move data from header file to driver
Date: Fri, 29 Mar 2013 15:31:48 -0400 (EDT)
Message-ID: <20130329.153148.2125905168028363965.davem@davemloft.net>
References: <201303290048.27020.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com,
	linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201303290048.27020.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Fri, 29 Mar 2013 00:48:26 +0300

> The driver's header file contains initialized register offset tables which (as
> any data definitions), of course, have no business being there.  Move them  to
> the driver's body, somewhat beautifying the initializers, while at it...
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied.
