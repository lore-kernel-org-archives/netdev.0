From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.5.0+ - Linus GIT - WARNING: at net/sched/sch_generic.c:255
 dev_watchdog+0xeb/0x15f()
Date: Fri, 08 Jun 2012 18:33:37 +0200
Message-ID: <1339173217.6001.129.camel@edumazet-glaptop>
References: <CAHFgRy9jgxOrF=b=oQd-zK5CKxDacOKdBAX_BEuyW+R+sK_GyQ@mail.gmail.com>
	 <1339051157.26966.97.camel@edumazet-glaptop>
	 <CAHFgRy-u3Xh=1XjrZi2x+=6bBdQ=Ve8i6jer9ppjYEWun70hxQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Wim Van Sebroeck <wim@iguana.be>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Huang Xiong <xiong@qca.qualcomm.com>
To: Miles Lane <miles.lane@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHFgRy-u3Xh=1XjrZi2x+=6bBdQ=Ve8i6jer9ppjYEWun70hxQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-06-08 at 12:26 -0400, Miles Lane wrote:

> I tested this patch as well and got the following (identical to the
> warning with the other patch you sent):

Is this card working on a previous kernel ?

If yes, you probably should do a bisection.
