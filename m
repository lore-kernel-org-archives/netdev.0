From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] netem: restart device after inserting packets
Date: Mon, 20 Dec 2004 15:43:26 -0800
Message-ID: <20041220154326.4eedb936.davem@davemloft.net>
References: <20041208123103.4cc6b005@dxpl.pdx.osdl.net>
	<20041208210031.63f0963f.davem@davemloft.net>
	<41B91901.3070304@trash.net>
	<20041214113249.0725a655.davem@davemloft.net>
	<20041214131113.32d080fb@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netem@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20041214131113.32d080fb@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 14 Dec 2004 13:11:13 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> 2.4 version of the netem wakeup patch. Also fixes the qlen
> in a couple of places. This makes code basically same as 2.6
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied, thanks a lot Stephen.
