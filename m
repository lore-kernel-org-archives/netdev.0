From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: sundance driver does not work with D-Link DFE-580TX
Date: Thu, 19 Jun 2003 13:19:50 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EF1F0B6.8020505@pobox.com>
References: <200305261604.h4QG4iQY020725@sandelman.ottawa.on.ca> <57880000.1056026633@worker.muc.bieringer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Peter Bieringer <pb@bieringer.de>
In-Reply-To: <57880000.1056026633@worker.muc.bieringer.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Peter Bieringer wrote:
> I (also others independed) finally find the bug:
> 
> RHL uses CONFIG_SUNDANCE_MMIO=y on kernel building which causes the
> problem. 


FWIW we've changed this to N.

	Jeff
