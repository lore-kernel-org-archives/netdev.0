From: Meelis Roos <mroos@linux.ee>
Subject: cls_u32 compile failure in current 2.6.12-rc1+BK tree
Date: Sun, 27 Mar 2005 22:49:54 +0300 (EEST)
Message-ID: <Pine.SOC.4.61.0503272249040.5086@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   CC [M]  net/sched/cls_u32.o
net/sched/cls_u32.c: In function `u32_dump':
net/sched/cls_u32.c:778: error: structure has no member named `action'
net/sched/cls_u32.c:778: error: structure has no member named `action'

-- 
Meelis Roos (mroos@linux.ee)
