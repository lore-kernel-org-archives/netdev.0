From: Paul Mackerras <paulus@samba.org>
Subject: Re: [patch] Re: Gigabit Kconfig problems with yesterday's update
Date: Mon, 31 May 2004 20:00:16 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16571.560.788601.739034@cargo.ozlabs.ibm.com>
References: <40B8A37D.1090802@myrealbox.com>
	<20040530134544.GE13111@fs.tum.de>
	<20040530143734.GA24627@dth.net>
	<20040530094120.61b22d2e.rddunlap@osdl.org>
	<40BA1F25.4080402@pobox.com>
	<20040530193706.GG13111@fs.tum.de>
	<Pine.LNX.4.58.0405301302020.1632@ppc970.osdl.org>
	<20040531073211.GA4894@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@osdl.org>, Adrian Bunk <bunk@fs.tum.de>,
        Jeff Garzik <jgarzik@pobox.com>, linux-kernel@vger.kernel.org,
        "Randy.Dunlap" <rddunlap@osdl.org>, Danny ter Haar <dth@dth.net>,
        wa1ter@myrealbox.com, dth@ncc1701.cistron.net,
        Netdev <netdev@oss.sgi.com>, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20040531073211.GA4894@infradead.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Christoph Hellwig writes:

> Or have a gige chip that's crippled to do only 10/100, like the sungem
> on my ibook.

I think it is not that the sungem itself is crippled, rather that the
phy can only do 10/100.  I agree that the division between 10/100 and
gigabit ethernet is pretty useless.  I note that sungem didn't get put
in the gigabit list, for instance.

Paul.
