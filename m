From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (2/3) tcp - diagnostics enhancement for westwood
Date: Mon, 27 Sep 2004 12:17:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927121746.7ab592d5.davem@redhat.com>
References: <20040927112118.4c376303@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040927112118.4c376303@zqx3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 27 Sep 2004 11:21:18 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Enhancement to tcp diagnostics used by ss command.
> * use jiffies_to_usecs/msec instead of hardcode math
> * report bandwidth for Westwood
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Looks great, applied.

Again, 2.4.x variant would be appreciated.

Thanks.
