From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][ATM]: [lec] put back pressure on network stack
Date: Thu, 26 Feb 2004 12:02:54 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040226120254.69d6f9a2.davem@redhat.com>
References: <200402252351.i1PNpJg5006282@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas3@users.sourceforge.net
In-Reply-To: <200402252351.i1PNpJg5006282@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 25 Feb 2004 18:51:21 -0500
"chas williams (contractor)" <chas@cmf.nrl.navy.mil> wrote:

> the lane client doesnt put back pressure on the network
> stack when one of the transmit vcc's is full.  this can
> yield spurious results with certain network performance
> tests.
> 
> please apply to 2.6 --thanks

Applied, thanks Chas.
