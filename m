From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6]: Missing dev_put in qdisc_create error path
Date: Sun, 22 Aug 2004 21:49:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040822214940.59309136.davem@redhat.com>
References: <412894BB.9090906@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <412894BB.9090906@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 22 Aug 2004 14:42:35 +0200
Patrick McHardy <kaber@trash.net> wrote:

> This patch fixes missing dev_puts in qdisc_create and
> qdisc_create_dflt error paths.

Applied, thanks Patrick.
