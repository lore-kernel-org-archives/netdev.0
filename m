From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] [IPVS] Fixed that the WRR scheduler works correctly
 when server is updated or overloaded
Date: Wed, 9 Mar 2005 20:36:12 -0800
Message-ID: <20050309203612.6228f0a8.davem@davemloft.net>
References: <Pine.LNX.4.61.0502150054180.2895@penguin.linux-vs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Wensong Zhang <wensong@linux-vs.org>
In-Reply-To: <Pine.LNX.4.61.0502150054180.2895@penguin.linux-vs.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Feb 2005 01:00:38 +0800 (CST)
Wensong Zhang <wensong@linux-vs.org> wrote:

> Here is the patch to make the WRR scheduler work correctly when server is 
> updated with new weight or marked overloaded. Please check and apply it to 
> kernel 2.6.

Applied, thanks Wensong.
