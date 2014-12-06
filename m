From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skge: Unmask interrupts in case of spurious interrupts
Date: Fri, 05 Dec 2014 21:34:18 -0800 (PST)
Message-ID: <20141205.213418.1220384750443838103.davem@davemloft.net>
References: <1417348291-1302-1-git-send-email-LinoSanfilippo@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, mlindner@marvell.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: LinoSanfilippo@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417348291-1302-1-git-send-email-LinoSanfilippo@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Date: Sun, 30 Nov 2014 12:51:31 +0100

> In case of a spurious interrupt dont forget to reenable the interrupts that
> have been masked by reading the interrupt source register.
> 
> Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>

Applied.
