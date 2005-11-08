From: Adrian Bunk <bunk@stusta.de>
Subject: Future of DONGLE_OLD drivers?
Date: Tue, 8 Nov 2005 04:42:26 +0100
Message-ID: <20051108034226.GL3847@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932202AbVKHDma@vger.kernel.org>
To: Jean Tourrilhes <jt@hpl.hp.com>, rmk@arm.linux.org.uk
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Looking at drivers/net/irda/Kconfig, it seems all DONGLE_OLD drivers 
except EP7211_IR have more recent drivers.

My questions are:

Is there still any reason to keep the DONGLE_OLD drivers except 
EP7211_IR?

Is the Cirrus Logic EDB-7211 evaluation board still an actively 
maintained and supported platform or an obsolete platform?

TIA
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
