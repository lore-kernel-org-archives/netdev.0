From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] remove FCS from pktgen bandwidth calculation
Date: Thu, 9 Dec 2004 15:59:36 -0800
Message-ID: <20041209155936.69313e70.davem@davemloft.net>
References: <20041208201116.GA10691@xi.wantstofly.org>
	<16824.22466.897897.238619@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: buytenh@wantstofly.org, Robert.Olsson@data.slu.se, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16824.22466.897897.238619@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 9 Dec 2004 14:48:50 +0100
Robert Olsson <Robert.Olsson@data.slu.se> wrote:

> OK! We strictly define statistics to be based on the data we deliver
> to hard_xmit. Feel free to change the current kernel version... while
> we wait for 2.7 :-)

Robert can you collect together the various pktgen patches
that have been floating about over the past few days and
send to me what you think should be applied.

There is this FCS patch, and the naonspin one from Lennert
as well.  There may have been others.
