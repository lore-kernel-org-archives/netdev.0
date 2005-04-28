From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6.11.7] sch_htb: Drop packet when direct queue is full
Date: Thu, 28 Apr 2005 12:04:04 -0700
Message-ID: <20050428120404.190d7344.davem@davemloft.net>
References: <Pine.LNX.4.61.0504251409560.24260@limnos.csrd.uiuc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Asim Shankar <asimshankar@gmail.com>
In-Reply-To: <Pine.LNX.4.61.0504251409560.24260@limnos.csrd.uiuc.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 25 Apr 2005 14:15:05 -0500 (CDT)
Asim Shankar <asimshankar@gmail.com> wrote:

> htb_enqueue(): Free skb and return NET_XMIT_DROP if a packet is destined 
> for the direct_queue but the direct_queue is full. (Before patch: 
> Erroneously returned NET_XMIT_SUCCESS even though packet was not enqueued)
> 
> Signed-off-by: Asim Shankar <asimshankar@gmail.com>

Your patch is mangled by your email client.  The non-changing lines
in the patch have two leading spaces, which is wrong.  So the patch
will not apply.
