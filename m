From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.4.21][FIX] use mod_timer
Date: Fri, 20 Jun 2003 10:05:00 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030620.100500.41646097.davem@redhat.com>
References: <1056091000.1200.23.camel@lima.royalchallenge.com>
	<Mutt.LNX.4.44.0306201907450.27218-100000@excalibur.intercode.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay-rc@naturesoft.net, marcelo@hera.kernel.org, netdev@oss.sgi.com,
   jbarnes@sgi.com, alan@redhat.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jmorris@intercode.com.au
In-Reply-To: <Mutt.LNX.4.44.0306201907450.27218-100000@excalibur.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: James Morris <jmorris@intercode.com.au>
   Date: Fri, 20 Jun 2003 19:10:50 +1000 (EST)
   
   FYI, the status of the networking patches is:
   
                        2.5-bk   2.4.21-ac1    2.4-bk
   net/core/dst.c        yes        no           no
   net/sched/sch_cbq.c   yes       yes           no
   net/sched/sch_csz.c   yes       yes           no
   net/sched/sch_htb.c   yes       yes           no

They are, however, in my BK tree and I did attempt to push
them to Marcelo so nights ago.
