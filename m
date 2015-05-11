From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: ll_temac: Use one return statement instead of
 two
Date: Mon, 11 May 2015 14:16:43 -0400 (EDT)
Message-ID: <20150511.141643.1570113271442981674.davem@davemloft.net>
References: <3a0fa74dd703db5dac4816ef15b6a512ef0f2ec0.1431353091.git.michal.simek@xilinx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, soren.brinkmann@xilinx.com,
	monstr@monstr.eu, fabf@skynet.be, linux-kernel@vger.kernel.org,
	manuel.schoelling@gmx.de, julia.lawall@lip6.fr,
	elfring@users.sourceforge.net, subbaraya.sundeep.bhatta@xilinx.com,
	linux-arm-kernel@lists.infradead.org
To: michal.simek@xilinx.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3a0fa74dd703db5dac4816ef15b6a512ef0f2ec0.1431353091.git.michal.simek@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Simek <michal.simek@xilinx.com>
Date: Mon, 11 May 2015 16:05:02 +0200

> Use one return statement instead of two to simplify the code.
> Both are returning the same value.
> 
> Signed-off-by: Michal Simek <michal.simek@xilinx.com>

Applied, thanks.
