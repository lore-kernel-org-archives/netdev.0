From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] (1/3) tcp - choose congestion algorithm at
 initialization
Date: Sun, 3 Oct 2004 14:52:02 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041003145202.6fe994fb.davem@davemloft.net>
References: <20040927111834.48c7baab@zqx3.pdx.osdl.net>
	<20040927121610.68f942a4.davem@redhat.com>
	<20041001155554.51763dc0@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20041001155554.51763dc0@zqx3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 1 Oct 2004 15:55:54 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Here is the 2.4 version of the change to store congest algorithm
> per socket.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied, thanks for following up on this Stephen.
