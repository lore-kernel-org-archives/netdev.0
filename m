From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch] Re: Gigabit Kconfig problems with yesterday's update
Date: Mon, 31 May 2004 08:32:11 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040531073211.GA4894@infradead.org>
References: <40B8A37D.1090802@myrealbox.com> <20040530134544.GE13111@fs.tum.de> <20040530143734.GA24627@dth.net> <20040530094120.61b22d2e.rddunlap@osdl.org> <40BA1F25.4080402@pobox.com> <20040530193706.GG13111@fs.tum.de> <Pine.LNX.4.58.0405301302020.1632@ppc970.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Adrian Bunk <bunk@fs.tum.de>, Jeff Garzik <jgarzik@pobox.com>,
	linux-kernel@vger.kernel.org, "Randy.Dunlap" <rddunlap@osdl.org>,
	Danny ter Haar <dth@dth.net>, wa1ter@myrealbox.com,
	dth@ncc1701.cistron.net, Netdev <netdev@oss.sgi.com>,
	Andrew Morton <akpm@osdl.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S262388AbUEaHcc@vger.kernel.org>
To: Linus Torvalds <torvalds@osdl.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0405301302020.1632@ppc970.osdl.org>
List-Id: netdev.vger.kernel.org

On Sun, May 30, 2004 at 01:06:53PM -0700, Linus Torvalds wrote:
> is it really sane these days to split out gigabit from the "regular" 
> ethernets? gigabit ethernet is getting quite a bit more common than it 
> used to be, and a lot of the gigabit devices are just "standard ethernet" 
> as far as the user is concerned, and in fact they are often _used_ in just 
> regular 10/100Mbps setups.

Or have a gige chip that's crippled to do only 10/100, like the sungem
on my ibook.
