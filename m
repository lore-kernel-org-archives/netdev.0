From: Adrian Bunk <bunk@stusta.de>
Subject: SCTP: use lib/libcrc32c.c instead of net/sctp/crc32c.c?
Date: Fri, 13 May 2005 15:50:04 +0200
Message-ID: <20050513135004.GG3603@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sri@us.ibm.com, lksctp-developers@lists.sourceforge.net,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Clay Haapala <chaapala@cisco.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

As far as I understand it, lib/libcrc32c.c could be used instead of the 
similar code in net/sctp/crc32c.c .

Is there any reason why this isn't done?

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
