From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (1/3) tcp - choose congestion algorithm at
 initialization
Date: Mon, 27 Sep 2004 12:16:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927121610.68f942a4.davem@redhat.com>
References: <20040927111834.48c7baab@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040927111834.48c7baab@zqx3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 27 Sep 2004 11:18:34 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> The choice of congestion algorithm needs to be made when connection
> is setup to avoid problems when the sysctl values change later and the
> necessary data hasn't been collected.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Looks great, applied.

We'll need 2.4.x versions of this stuff, could you cook
those up for me?

Thanks.
