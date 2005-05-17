From: Andi Kleen <ak@muc.de>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Tue, 17 May 2005 21:17:30 +0200
Message-ID: <m1sm0l7jcl.fsf@muc.de>
References: <Pine.LNX.4.61.0505170914130.29021@linux.site>
	<20050517.104947.112621738.davem@davemloft.net>
	<m1zmut7l5q.fsf@muc.de> <200505171457.38719.jheffner@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        akepner@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <200505171457.38719.jheffner@psc.edu> (John Heffner's message
 of "Tue, 17 May 2005 14:57:38 -0400")
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

John Heffner <jheffner@psc.edu> writes:

>
> It would be better still to have a per-route packet reassembly timeout in 
> milliseconds.  Expecting perfect ordering seems very fragile even for a LAN.

In fact I implemented that a long time ago for the SUSE 2.4 kernel.
But for some reason nobody liked it very much, so I never submitted it.

I can dig out the old patches if there is interest.

-Andi
