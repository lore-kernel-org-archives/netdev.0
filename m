From: Mike_Phillips@URSCorp.com
Subject: Re: [PATCH] (5/6) ibmtr -- probe2
Date: Fri, 17 Oct 2003 10:40:18 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF5562F390.D263B48B-ON84256DC2.004AECA7-84256DC2.004B19D6@urscorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, netdev-bounce@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On a more general note: ibmtr and ibmtr_cs are just plain evil and have
lots of little quirks in them because of the multitude of different
adapters available that actually use the tropic chipset.

Jeff: Please don't apply until I get a chance to try this out with real
hardware.

Thanks
Mike
