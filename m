From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (3/3) tcp westwood cleanup
Date: Mon, 27 Sep 2004 12:18:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927121838.21f260ef.davem@redhat.com>
References: <20040927112249.38bea6ff@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040927112249.38bea6ff@zqx3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 27 Sep 2004 11:22:49 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Westwood code cleanup;
> 	* use const.
> 	* avoid needless paren's and returns
> 	* inline acked_count (called once)

Looks good, applied.
