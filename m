From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Allow lapb to be unloaded.
Date: Sat, 19 Jul 2003 21:47:12 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030719214712.3a0c9b0a.davem@redhat.com>
References: <20030718133211.1c7ed08d.shemminger@osdl.org>
	<20030718150101.0558d04e.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: eis@baty.hanse.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030718150101.0558d04e.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 18 Jul 2003 15:01:01 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Without an exit routine lapb can't be unloaded.

Applied, thanks.
