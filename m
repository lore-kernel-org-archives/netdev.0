From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: ethernet QoS support?
Date: Thu, 08 Jul 2004 15:01:48 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40ED9A1C.4040707@pobox.com>
References: <1C440F3C-D110-11D8-8B61-000393DBC2E8@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: Kumar Gala <kumar.gala@freescale.com>
In-Reply-To: <1C440F3C-D110-11D8-8B61-000393DBC2E8@freescale.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Kumar Gala wrote:
> Jeff,
> 
> I was wondering if there was any support for handling ethernet devices 
> that support multiple RX/TX queues to provide QoS.  If so any pointers 
> would be great.

IIRC skb->priority provides priority bands for TX.  Not sure about RX... 
jamal?

	Jeff
