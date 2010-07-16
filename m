From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/nuc900: enable Mac driver clock
Date: Thu, 15 Jul 2010 19:07:57 -0700 (PDT)
Message-ID: <20100715.190757.70186039.davem@davemloft.net>
References: <4C3D87FD.6030101@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: mcuos.com@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C3D87FD.6030101@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wan ZongShun <mcuos.com@gmail.com>
Date: Wed, 14 Jul 2010 17:48:45 +0800

> This patch fixed a bug that Mac driver does not work,because I missed the clk enable.
> 
> I have ever tested the driver when I submitted previous Mac driver patch,
> and it worked good, since my bootloader has enabled the clock in advance.
> 
> But when I try to use other bootloader where clock engine was disabled,the
> Mac driver does not work, so I send this patch to fix this issue.
> 
> Signed-off-by: Wan ZongShun <mcuos.com@gmail.com>

Applied, thank you.
