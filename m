From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ec_bhf: Use module_pci_driver
Date: Wed, 08 Jul 2015 16:04:23 -0700 (PDT)
Message-ID: <20150708.160423.2249509547518290972.davem@davemloft.net>
References: <20150707070254.GA18958@vaishali-Ideapad-Z570>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: reksio@newterm.pl, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: vthakkar1994@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150707070254.GA18958@vaishali-Ideapad-Z570>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vaishali Thakkar <vthakkar1994@gmail.com>
Date: Tue, 7 Jul 2015 12:32:54 +0530

> Use module_pci_driver for drivers whose init and exit functions
> only register and unregister, respectively.
> 
> A simplified version of the Coccinelle semantic patch that performs
> this transformation is as follows:
 ...
> Signed-off-by: Vaishali Thakkar <vthakkar1994@gmail.com>

Applied to net-next, thanks.
