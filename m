From: Andres Salomon <dilinger@athenacr.com>
Subject: Re: Status of net/ipv4/ipvs/ip_vs_proto_icmp.c?
Date: Fri, 13 May 2005 15:09:01 -0400
Message-ID: <pan.2005.05.13.19.09.00.598647@athenacr.com>
References: <20050513041622.GE3603@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 13 May 2005 06:16:22 +0200, Adrian Bunk wrote:

> Hi,
> 
> can anyone explain the status of?
> 
> This file is always included in the kernel if CONFIG_IP_VS=y, but it's 
> completely unused.
> 
> Will it be made working in the forseeable future or is it a candidate 
> for removal?
> 
> TIA
> Adrian

The people/places to ask would probably be:

IPVS
P:      Wensong Zhang
M:      wensong@linux-vs.org
P:      Julian Anastasov
M:      ja@ssi.bg
S:      Maintained

or

http://www.linuxvirtualserver.org/mailing.html
