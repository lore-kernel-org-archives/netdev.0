From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH]] New: tcp_input.c:3038 missing newline character
Date: Mon, 20 Dec 2004 15:30:23 -0800
Message-ID: <20041220153023.3f5cccee.davem@davemloft.net>
References: <200412202215.iBKMFSCr025060@fire-1.osdl.org>
	<20041220144120.5dfb4ee2@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20041220144120.5dfb4ee2@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 20 Dec 2004 14:41:20 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> http://bugme.osdl.org/show_bug.cgi?id=3924
> The printk at net/ipv4/tcp_input.c:3038 is missing the newline (\n) character.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied, thanks Stephen.
