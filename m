From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 05/10] parisc: use RCU to find network device
Date: Tue, 10 Nov 2009 22:48:49 -0800 (PST)
Message-ID: <20091110.224849.111240268.davem@davemloft.net>
References: <20091110175446.280423729@vyatta.com>
	<20091110175647.480041042@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kyle@mcmartin.ca, deller@gmx.de, a.beregalov@gmail.com,
	netdev@vger.kernel.org, linux-parisc@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <20091110175647.480041042@vyatta.com>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 10 Nov 2009 09:54:51 -0800

> Another place where RCU can be used instead of read_lock(&dev_base_lock)
> This is by inspection, don't have platform or cross-build environment
> to validate.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
