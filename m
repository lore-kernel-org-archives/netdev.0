From: jamal <hadi@cyberus.ca>
Subject: Re: cls_u32 compile failure in current 2.6.12-rc1+BK tree
Date: 27 Mar 2005 20:07:15 -0500
Message-ID: <1111972035.1091.946.camel@jzny.localdomain>
References: <Pine.SOC.4.61.0503272249040.5086@math.ut.ee>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>
To: Meelis Roos <mroos@linux.ee>
In-Reply-To: <Pine.SOC.4.61.0503272249040.5086@math.ut.ee>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi there,
For now just turn on actions under qos menu.
The solution needs some thought or major surgery.

cheers,
jamal

On Sun, 2005-03-27 at 14:49, Meelis Roos wrote:
>    CC [M]  net/sched/cls_u32.o
> net/sched/cls_u32.c: In function `u32_dump':
> net/sched/cls_u32.c:778: error: structure has no member named `action'
> net/sched/cls_u32.c:778: error: structure has no member named `action'
