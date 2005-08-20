From: Adrian Bunk <bunk@stusta.de>
Subject: 2.6.13-rc6-mm1: why is PHYLIB a user-visible option?
Date: Sat, 20 Aug 2005 02:20:27 +0200
Message-ID: <20050820002027.GJ3615@stusta.de>
References: <20050819043331.7bc1f9a9.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932349AbVHTAUa@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>, jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20050819043331.7bc1f9a9.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Is there any reason why PHYLIB is a user-visible option?

As far as I understand it, PHYLIB and the MII PHY device drivers are an 
internal library drivers should start to use roughly similar to MII.

But in this case, the options shouldn't be user-visible.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
