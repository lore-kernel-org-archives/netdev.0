From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] LLC -- get rid of warning
Date: Tue, 23 Sep 2003 13:58:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030923135818.1224f6fe.davem@redhat.com>
References: <20030923135426.4f85b7fb.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: acme@conectiva.com.br, mikep@linuxtr.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030923135426.4f85b7fb.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 23 Sep 2003 13:54:26 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> In 2.6.0-test5 bk latest, if token ring is configured, then a warning is
> generated about a missing prototype for tr_source_route.

Applied, thanks.
