From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Fw: [BUG/PATCH] CONFIG_NET_HW_FLOWCONTROL and SMP
Date: Mon, 29 Sep 2003 17:39:29 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F78A691.1040406@pobox.com>
References: <20030929123734.5bd97a47.akpm@osdl.org> <16248.41796.797321.700866@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com, dfages@arkoon.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16248.41796.797321.700866@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Robert Olsson wrote:
> Hello!
> 
> IMO HW_FLOWCONTROL is now outdated. It has served very well and encouraged 
> people to use for Linux production networking. With a 2 tulip NIC's on a UP 
> system as a typical system. Only tulip has code for it. This option was 
> added by Alexey in 2.1.63 something...


If someone had a NAPI patch for tulip, we could remove HW_FLOWCONTROL 
option altogether :)

	Jeff
