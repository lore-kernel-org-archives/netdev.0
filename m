From: David Miller <davem@redhat.com>
Subject: Re: [PATCH 1/2] phy/micrel: Add support for KSZ8031
Date: Tue, 12 Mar 2013 06:55:27 -0400 (EDT)
Message-ID: <20130312.065527.477313007496838625.davem@redhat.com>
References: <1362991803-4610-1-git-send-email-hector.palacios@digi.com>
	<201303111339.46507.marex@denx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hector.palacios@digi.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: marex@denx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201303111339.46507.marex@denx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marek Vasut <marex@denx.de>
Date: Mon, 11 Mar 2013 13:39:46 +0100

> Dear Hector Palacios,
> 
>> Micrel PHY KSZ8031 is similar to KSZ8021 and also requires the special
>> initialization of "Operation Mode Strap Override" in reg 0x16
>> introduced in 212ea99 (phy/micrel: Implement support for KSZ8021).
>> 
>> Signed-off-by: Hector Palacios <hector.palacios@digi.com>
> 
> I dont have any board with this one, yet I think this change is correct, so:
> 
> Reviewed-by: Marek Vasut <marex@denx.de>

Applied.
