From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] netem: use timer to handle packets not rescheduling
Date: Fri, 22 Oct 2004 15:15:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041022151516.411e1385.davem@davemloft.net>
References: <20041022125303.6c4c979a@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20041022125303.6c4c979a@zqx3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 22 Oct 2004 12:53:03 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Change the behaviour of netem's delayed packets queue to make it work better
> with TBF and other rate control disciplines.

Applied, thanks Stephen.  Can you cook up a 2.4.x version?
Thanks.
