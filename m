From: Pekka Pietikainen <pp@ee.oulu.fi>
Subject: Re: [patch] 2.4 lacks dummy SET_NETDEV_DEV
Date: Tue, 11 Nov 2003 00:14:30 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031110221430.GA26556@ee.oulu.fi>
References: <20031110181917.GA25846@ee.oulu.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20031110181917.GA25846@ee.oulu.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Nov 10, 2003 at 08:19:17PM +0200, Pekka Pietikainen wrote:
> Just noticed that 2.4 doesn't have a dummy SET_NETDEV_DEV for drivers
> written for 2.6 (like the b44 fixes that got merged a few days back, so
> it wouldn't actually compile :-) )
Ah, except Jeff merged a version without the call so there should be no
problem :-) (I still like the idea of being able to use exactly the same driver
source on 2.4/2.6 though)
