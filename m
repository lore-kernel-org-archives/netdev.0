From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] [IPVS] update mark->cw in the WRR scheduler while
 service is updated
Date: Wed, 9 Mar 2005 20:37:40 -0800
Message-ID: <20050309203740.5e8d2a0a.davem@davemloft.net>
References: <Pine.LNX.4.61.0502151559090.5935@penguin.linux-vs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, ja@ssi.bg
To: Wensong Zhang <wensong@linux-vs.org>
In-Reply-To: <Pine.LNX.4.61.0502151559090.5935@penguin.linux-vs.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Feb 2005 16:03:10 +0800 (CST)
Wensong Zhang <wensong@linux-vs.org> wrote:

> This is the patch for the WRR scheduler in IPVS of kernel 2.4. It's a fix 
> for better performance when server weight is adjusted. Please check and 
> apply it to kernel 2.4.

Also applied, thanks Wensong.
