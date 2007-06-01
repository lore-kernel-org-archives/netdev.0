From: "Jeff Haran" <jharan@Brocade.COM>
Subject: RE: ETHTOOL_GSET IOCTL on GigE links
Date: Fri, 1 Jun 2007 16:09:29 -0700
Message-ID: <46F9780F64AE9945815725F4C0C72CB803026275@hq-exch-1.corp.brocade.com>
References: <4660A604.4080701@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <linux-net@vger.kernel.org>, "netdev" <netdev@vger.kernel.org>
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <linux-net-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <4660A604.4080701@garzik.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Jeff Garzik [mailto:jeff@garzik.org] 
> Sent: Friday, June 01, 2007 4:05 PM
> To: Jeff Haran
> Cc: linux-net@vger.kernel.org; netdev
> Subject: Re: ETHTOOL_GSET IOCTL on GigE links
> 
> Jeff Haran wrote:
> > OK, but my question remains. In the case where a device 
> supports one set
> > of speeds via autonegotiation and another set via forcing, 
> how does one
> > tell which speeds can be forced and which can be autonegotiated?
> 
> The interface does not currently support such enumeration.
> 
> You can certainly attempt forcing a speed, and see what happens.  The 
> driver will either (a) work, (b) refuse and give you an error 
> message, 
> or (c) present you with a situation that requires filing a driver bug 
> report :)
> 
> 	Jeff

Are there any plans in the works to modify the interface to provide this
information?

Thanks,

Jeff Haran
