From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFT][PATCH] convert 802/tr to seq_file
Date: Tue, 19 Aug 2003 21:23:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819212314.3356d22a.davem@redhat.com>
References: <20030819141326.2a63bad0.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mikep@linuxtr.net, linux-tr@linuxtr.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030819141326.2a63bad0.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 19 Aug 2003 14:13:26 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Convert the /proc interface to tokenring routing information
> to the new seq_file interface.

Applied, thanks.

Please make the coding style cleanups suggested by Francois
in the next round.
