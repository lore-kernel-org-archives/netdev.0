From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (2/3) tcp - diagnostics enhancement for westwood
Date: Mon, 27 Sep 2004 14:16:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927141655.5e53ca7a.davem@redhat.com>
References: <20040927112118.4c376303@zqx3.pdx.osdl.net>
	<20040927121746.7ab592d5.davem@redhat.com>
	<20040927132418.509c689b@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: joe@Perches.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040927132418.509c689b@zqx3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 27 Sep 2004 13:24:18 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Joe's suggestion, put jiffies_to_usecs in time.h and make it smarter
> about HZ values math.

Works for me.

Applied, thanks Stephen/Joe.
