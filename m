From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] tcp_diag.c -- use static,const,void
Date: Sat, 20 Sep 2003 00:27:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030920002724.359d9139.davem@redhat.com>
References: <20030919100632.48dd8e27.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030919100632.48dd8e27.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 19 Sep 2003 10:06:32 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Cleanup internals of tcp_diag.c.  Make functions static, use const for
> parameters in match functions, use void * when generic ptr is intended.

Applied, thanks Stephen.
