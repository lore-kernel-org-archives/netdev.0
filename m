From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.4] PKT_SCHED: Rename TCQ_F_INGRES to TCQ_F_INGRESS
Date: Mon, 25 Oct 2004 20:26:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041025202647.5f4d5163.davem@davemloft.net>
References: <20041022230731.GL21977@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041022230731.GL21977@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Both 2.4.x and 2.6.x variants applied, thanks Thomas.

Speaking of grep'ability, I will always apply patches that make
structure members easier to grep for in the kernel sources.
One great example is when Arnaldo added the "sk_*" prefix
to the names of the members of struct sock.
