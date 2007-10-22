From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Subject: Re: kernel panic when running tcpdump
Date: Mon, 22 Oct 2007 23:16:22 +0200
Message-ID: <200710222316.22922.m.kozlowski@tuxland.pl>
References: <20071011213126.cf92efb7.akpm@linux-foundation.org> <200710222040.19921.m.kozlowski@tuxland.pl> <20071022120359.26403bf0.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-ppp@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <20071022120359.26403bf0.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > 	I'm seeing reproducible oops on 2.6.23-mm1 when trying to run tcpdump
> > over ppp0 interface.
> 
> Can you please test the latest Linus kernel from
> ftp://ftp.kernel.org/pub/linux/kernel/v2.6/snapshots/?

Sure.

> Because all netwrking things which were in 2.6.23-mm1 are now in mainline.
> So if mainline is OK then that bug presumably got fixed.

You're right. 2.6.23-git17 runs fine so the bug must have been fixed.

Regards,

	Mariusz
