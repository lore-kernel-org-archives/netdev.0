From: jamal <hadi@cyberus.ca>
Subject: Re: ethernet QoS support?
Date: 08 Jul 2004 16:00:46 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1089316845.1072.1.camel@jzny.localdomain>
References: <1C440F3C-D110-11D8-8B61-000393DBC2E8@freescale.com>
	 <40ED9A1C.4040707@pobox.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Kumar Gala <kumar.gala@freescale.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <40ED9A1C.4040707@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-07-08 at 15:01, Jeff Garzik wrote:
> Kumar Gala wrote:
> > Jeff,
> > 
> > I was wondering if there was any support for handling ethernet devices 
> > that support multiple RX/TX queues to provide QoS.  If so any pointers 
> > would be great.
> 
> IIRC skb->priority provides priority bands for TX.  Not sure about RX... 
> jamal?

The question was very ambigous. 
What is it that Kumar is looking for? Is it 802.1p, IP level etc?

cheers,
jamal
