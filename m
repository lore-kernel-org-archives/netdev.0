From: Jean Delvare <khali@linux-fr.org>
Subject: Re: [patch 1/9] eeprom_93cx6: Add data direction control.
Date: Mon, 7 Dec 2009 13:21:41 +0100
Message-ID: <20091207132141.1db65cd3@hyperion.delvare>
References: <20091207121727.016092171@fluff.org.uk>
	<20091207121827.433183360@fluff.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux@simtec.co.uk, doong.ping@micrel.com,
	tristram.ha@micrel.com, Wolfram Sang <w.sang@pengutronix.de>,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: Ben Dooks <ben@simtec.co.uk>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934798AbZLGMVm@vger.kernel.org>
In-Reply-To: <20091207121827.433183360@fluff.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 07 Dec 2009 12:17:28 +0000, Ben Dooks wrote:
> Some devices need to know if the data is to be output or read, so add a
> data direction into the eeprom structure to tell the driver whether the
> data line should be driven.
> 
> The user in this case is the Micrel KS8851 which has a direction
> control for the EEPROM data line and thus needs to know whether
> to drive it (writing) or to tristate it for receiving.
> 
> Signed-off-by: Ben Dooks <ben@simtec.co.uk>
> Cc: Wolfram Sang <w.sang@pengutronix.de>
> Cc: Jean Delvare <khali@linux-fr.org>
> Cc: Linux Kernel <linux-kernel@vger.kernel.org>

FYI, I will not be reviewing this patch nor any other patch to the
eeprom_93cx6 driver. I have no clue what these devices are, no access
to any and no interest in them either.

-- 
Jean Delvare
