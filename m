From: "Matthew G. Marsh" <mgm@paktronix.com>
Subject: Re: [PATCH 2.5.72] Red Creek VPN update
Date: Fri, 5 Sep 2003 09:08:58 -0500 (CDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.53.0309050906170.20033@netmonster.pakint.net>
References: <20030617163116.1f7b6d78.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030617163116.1f7b6d78.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 17 Jun 2003, Stephen Hemminger wrote:

> Some cleanup's to Red Creek VPN driver.
> 	- use alloc_etherdev instead of init_etherdev
> 	- don't decrement module ref count negative in case of error.
>
> Don't have the hardware to actually test the real thing. But the driver builds
> and loads fine.

Hi - sorry for the late response - I have 57 of these in production. I am
now trying to get together a 2.6test machine and this is one of the first
parts I will test.

How would you like bug reports? I will try to gen patches where possible
but I don't have bk.

Thank you for your work on this!

--------------------------------------------------
Matthew G. Marsh,  President
Paktronix Systems LLC
1506 North 59th Street
Omaha  NE  68104
Phone: (402) 553-2288
Email: mgm@paktronix.com
WWW:  http://www.paktronix.com
--------------------------------------------------
