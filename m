From: "David S. Miller" <davem@redhat.com>
Subject: Re: [patch 1/1] err2-15: ax25_rt_add() locking fix
Date: Mon, 5 Jul 2004 16:05:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040705160516.10c1b23e.davem@redhat.com>
References: <200407020847.i628lLG23044@mail.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org
In-Reply-To: <200407020847.i628lLG23044@mail.osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 02 Jul 2004 01:46:23 -0700
akpm@osdl.org wrote:

> It can return with the lock held.
> 
> Found by the Stanford locking checker
> 
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Applied.
