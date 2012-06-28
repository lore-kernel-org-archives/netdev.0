From: Nix <nix@esperi.org.uk>
Subject: Re: 3.4.x regression: rtl8169: frequent resets
Date: Fri, 29 Jun 2012 00:42:50 +0100
Message-ID: <877gurovet.fsf@spindle.srvr.nix>
References: <87y5n7qup0.fsf@spindle.srvr.nix>
	<20120628193026.GA31627@electric-eye.fr.zoreil.com>
	<201206290131.49150.s.L-H@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Stefan Lippers-Hollmann" <s.L-H@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201206290131.49150.s.L-H@gmx.de> (Stefan Lippers-Hollmann's
	message of "Fri, 29 Jun 2012 01:31:42 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 29 Jun 2012, Stefan Lippers-Hollmann uttered the following:
> I received the same oops from a 3.4.4 user with these onboard network 
> cards:

Pedant point: it's not an oops, just a slowpath warning.

>                                                        no oops in 21
> hours uptime so far (while it usually shows up within about an hour).

Interesting. I wonder why it took two days to show up for me. It's not
like I'm a very light network user or anything, there are easily 300
packets per second in each direction on this interface every second of
the day (and often much more).

-- 
NULL && (void)
