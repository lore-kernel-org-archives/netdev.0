From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] vlan: eliminate gcc warnings with PROC_FS=n
Date: Tue, 25 Jan 2005 21:43:13 -0800
Message-ID: <20050125214313.05a34248.davem@davemloft.net>
References: <41F5DC6E.8070203@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Randy.Dunlap" <rddunlap@osdl.org>
In-Reply-To: <41F5DC6E.8070203@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 24 Jan 2005 21:43:10 -0800
"Randy.Dunlap" <rddunlap@osdl.org> wrote:

> 
> Eliminate gcc warnings when PROC_FS=n:
> net/8021q/vlan.c:232: warning: statement with no effect
> net/appletalk/ddp.c:1893: warning: statement with no effect
> 
> Signed-off-by: Randy Dunlap <rddunlap@osdl.org>

Applied, thanks Randy.
