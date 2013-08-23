From: Eric Wong <normalperson@yhbt.net>
Subject: Re: [PATCH RFC net-next] net: epoll support for busy poll
Date: Fri, 23 Aug 2013 20:36:56 +0000
Message-ID: <20130823203656.GA474@dcvr.yhbt.net>
References: <20130821103954.30607.6819.stgit@ladj378.jer.intel.com>
 <20130822201135.GA4088@dcvr.yhbt.net>
 <52170E78.1010704@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Eilon Greenstein <eilong@broadcom.com>,
	Amir Vadai <amirv@mellanox.com>,
	Eric Dumazet <erdnetdev@gmail.com>,
	Willem de Bruijn <willemb@google.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <52170E78.1010704@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eliezer Tamir <eliezer.tamir@linux.intel.com> wrote:
> I'm not sure I understand your claim that epoll has a higher latency
> than poll.

Nevermind, I usually live in an EPOLLONESHOT bubble so I use more
epoll_ctl than "normal" epoll apps :x

Anyways, good to know epoll wins over poll.  Thanks.
