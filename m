From: Adrian Bunk <bunk@stusta.de>
Subject: Status of net/ipv4/ipvs/ip_vs_proto_icmp.c?
Date: Fri, 13 May 2005 06:16:22 +0200
Message-ID: <20050513041622.GE3603@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262230AbVEMEQ1@vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>,
	Wensong Zhang <wensong@linuxvirtualserver.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

can anyone explain the status of?

This file is always included in the kernel if CONFIG_IP_VS=y, but it's 
completely unused.

Will it be made working in the forseeable future or is it a candidate 
for removal?

TIA
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
