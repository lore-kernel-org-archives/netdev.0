From: bert hubert <ahu@ds9a.nl>
Subject: Re: How to get IPv6 interface?
Date: Thu, 28 Nov 2002 12:16:00 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021128111600.GA30967@outpost.ds9a.nl>
References: <003201c29525$cd933360$6c06a8c0@zhengjp> <55380000.1038337716@worker.muc.bieringer.de> <004c01c29679$52812600$6c06a8c0@zhengjp> <8120000.1038471604@gate.muc.bieringer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <8120000.1038471604@gate.muc.bieringer.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Nov 28, 2002 at 09:20:04AM +0100, Peter Bieringer wrote:
> 
> 
> --On Thursday, November 28, 2002 08:58:53 AM +0800 Zheng Jianping
> <zjp@iscas.ac.cn> wrote:
> 
> > I'm writing an IPv6 application, so which function can get the IPv6
> > inteface information? And how to call it?
> 
> Sorry, I'm not really an IPv6 programmer, hopefully others can help
> you.

The best way is probably to look at the 'ip' sources which use netlink to
query the kernel.

> BTW: if someone has some written information about using the APIs,
> would be nice if can be contributed to the HowTo.

indeed.

Regards,

bert

-- 
http://www.PowerDNS.com          Versatile DNS Software & Services
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
