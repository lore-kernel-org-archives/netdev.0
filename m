From: bert hubert <ahu@ds9a.nl>
Subject: Re: ?completeness of IPsec feature-set
Date: Thu, 27 Mar 2003 14:36:59 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030327133659.GA11820@outpost.ds9a.nl>
References: <3E82DCF7.7090706@monmouth.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "John S. Denker" <jsd@monmouth.com>
Content-Disposition: inline
In-Reply-To: <3E82DCF7.7090706@monmouth.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Mar 27, 2003 at 06:13:59AM -0500, John S. Denker wrote:

> For example, consider the challenge of establishing an
> ordinary VPN where N-1 of the gateways have changeable
> wild-side IP addresses.  AFAICT nobody knows how to get
> racoon to do this.

Racoon is just an IKE daemon - Linux is not bound to it.  The OpenBSD one
(isakpmd)  also works under linux. You are free to write your own.

Regards,

bert

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
http://netherlabs.nl                         Consulting
