From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] [2.4.20] filter_list destroy fix in
	net/sched/sch_prio.c
Date: 12 Apr 2003 00:32:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1050132725.13106.2.camel@rth.ninka.net>
References: <E1B7C89B8DCB084C809A22D7FEB90B381773AD@frodo.avalon.ru>
	 <20030410135727.M86925@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dimitry V. Ketov" <Dimitry.Ketov@avalon.ru>, netdev@oss.sgi.com,
   linux-kernel@vger.kernel.org, "Alexey N. Kuznetsov" <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <20030410135727.M86925@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2003-04-10 at 10:57, jamal wrote:
> Looks good to me.

He missed sch_csz.c, I already sent a patch I wrote for this
to Linus and Marcelo will get a copy soon'ish.

-- 
David S. Miller <davem@redhat.com>
