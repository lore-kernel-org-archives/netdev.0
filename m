From: David Miller <davem@davemloft.net>
Subject: Re: NULL pointer dereference at netxen_nic_probe+0x813/0x9a0
Date: Sat, 30 Oct 2010 16:24:36 -0700 (PDT)
Message-ID: <20101030.162436.115938810.davem@davemloft.net>
References: <4CCB24CA.3050106@kernel.org>
	<20101029.125403.71123384.davem@davemloft.net>
	<4CCC7868.60104@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bjorn.helgaas@hp.com, amit.salecha@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: dkirjanov@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4CCC7868.60104@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Denis Kirjanov <dkirjanov@kernel.org>
Date: Sat, 30 Oct 2010 23:56:24 +0400

> [PATCH] netxen_nic: Fix the tx queue manipulation bug in netxen_nic_probe
> 
> We should not stop the egress queue during probe because it is wrong.
> 
> Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>

Applied.
