From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] tcp: efficient port randomisation (revised)
Date: Thu, 2 Dec 2004 13:52:52 -0800
Message-ID: <20041202135252.04e64f51.davem@davemloft.net>
References: <20041027092531.78fe438c@guest-251-240.pdx.osdl.net>
	<200411020854.44745.michael.vittrup.larsen@ericsson.com>
	<20041104100104.570e67cd@dxpl.pdx.osdl.net>
	<200411051103.59032.michael.vittrup.larsen@ericsson.com>
	<20041117153025.160eaa04@zqx3.pdx.osdl.net>
	<20041130214643.7b72300e.davem@davemloft.net>
	<20041201152446.3a0d5ce3@dxpl.pdx.osdl.net>
	<20041201204622.7b760400.davem@davemloft.net>
	<20041202134930.132d7bd8@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: michael.vittrup.larsen@ericsson.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20041202134930.132d7bd8@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2 Dec 2004 13:49:30 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> These are run on a relatively slow machine (2 way Pentium III 850Mhz)
> and it looks like the results are no change (in the noise).

Or averaged out, about 1ms more expensive.
