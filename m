From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] cpts fixes for v3.8-rc2
Date: Wed, 26 Dec 2012 14:15:40 -0800 (PST)
Message-ID: <20121226.141540.163930025578455864.davem@davemloft.net>
References: <cover.1356331925.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-omap@vger.kernel.org, cyril@ti.com, mugunthanvnm@ti.com,
	sshtylyov@mvista.com
To: richardcochran@gmail.com
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <cover.1356331925.git.richardcochran@gmail.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Richard Cochran <richardcochran@gmail.com>
Date: Mon, 24 Dec 2012 08:19:08 +0100

> Changed in v2:
> Use clk_prepare_enable instead of clk_prepare + clk_enable.
> 
> The new cpts driver has two small issues, but it otherwise seems to be
> working in -rc1.

Both applied, thanks.
