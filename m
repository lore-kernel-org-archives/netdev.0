From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vxge: Remember to release firmware after upgrading
 firmware
Date: Thu, 13 Jan 2011 21:50:34 -0800 (PST)
Message-ID: <20110113.215034.20934534.davem@davemloft.net>
References: <alpine.LNX.2.00.1101132119080.11347@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ramkrishna.vepa@exar.com, jon.mason@exar.com,
	sivakumar.subramani@exar.com, sreenivasa.honnur@exar.com
To: jj@chaosbits.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1101132119080.11347@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jj@chaosbits.net>
Date: Thu, 13 Jan 2011 21:25:20 +0100 (CET)

> Regardless of whether the firmware update being performed by 
> vxge_fw_upgrade() is a success or not we must still remember to always 
> release_firmware() before returning.
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>

Applied.
