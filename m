From: "David S. Miller" <davem@redhat.com>
Subject: Re: [patch 1/1] err1-28: rose_route locking fix
Date: Mon, 5 Jul 2004 16:02:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040705160259.472e5528.davem@redhat.com>
References: <200407020812.i628CFG17588@mail.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org
In-Reply-To: <200407020812.i628CFG17588@mail.osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 02 Jul 2004 01:11:17 -0700
akpm@osdl.org wrote:

> Fix deadlock in rose_del_loopback_node().  Found by the Stanford locking
> checker.
> 
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Applied.
