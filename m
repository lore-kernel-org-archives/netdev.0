From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Fix IPVS to set the statistics of dest zero
Date: Mon, 13 Oct 2003 12:32:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031013123256.0eaef28a.davem@redhat.com>
References: <Pine.LNX.4.44.0310132341300.1216-300000@penguin.linux-vs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, ja@ssi.bg
Return-path: <netdev-bounce@oss.sgi.com>
To: Wensong Zhang <wensong@linux-vs.org>
In-Reply-To: <Pine.LNX.4.44.0310132341300.1216-300000@penguin.linux-vs.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 13 Oct 2003 23:59:34 +0800 (CST)
Wensong Zhang <wensong@linux-vs.org> wrote:

> Here is the slight patch for IPVS to fix to zero the statistics of dest 
> when it is bound to a new service. It can make the statistics information 
> more correct after removing/adding new servers.
> 
> Please check the attached two patches and apply them to the kernel 2.4 and 
> 2.6 respectively.

Applied, thanks Wensong.
