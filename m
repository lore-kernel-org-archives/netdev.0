From: bert hubert <ahu@ds9a.nl>
Subject: Re: problem in IKE implementation.
Date: Fri, 16 Jul 2004 11:33:59 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040716093359.GA25457@outpost.ds9a.nl>
References: <BLEAIJDEHOOAGALIAAKBMEFICAAA.pranav@nodeinfotech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pranav <pranav@nodeinfotech.com>
Content-Disposition: inline
In-Reply-To: <BLEAIJDEHOOAGALIAAKBMEFICAAA.pranav@nodeinfotech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jul 16, 2004 at 11:20:31AM +0530, Pranav wrote:
> hi every one,
>            I am currently working on IKE implementation in linux system.i am
> facing a problem while when both the communating peers try to negotiate with
> each other at the same time resulting in a race condition.can any one help
> me regarding this issue.

I suggest reading the sources of racoon (or raccoon) or isakmpd to see how
they handle this.

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
