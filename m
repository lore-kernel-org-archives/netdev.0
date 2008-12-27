From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH] Makefile: disable sparse warning "returning void-valued expression"
Date: Sat, 27 Dec 2008 22:57:21 +0100
Message-ID: <20081227215721.GA19217@uranus.ravnborg.org>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net> <20081222191517.11807.20718.stgit@vmbox.hanneseder.net> <20081225.161740.10052019.davem@davemloft.net> <20081226115921.bb094c58.rdunlap@xenotime.net> <49567dd3.0b38560a.3c6c.0511@mx.google.com> <20081227192012.GB10592@uranus.ravnborg.org> <4956a360.0b38560a.3c6c.ffff9113@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Randy Dunlap <rdunlap@xenotime.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hannes Eder <hannes@hanneseder.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755022AbYL0Vz5@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4956a360.0b38560a.3c6c.ffff9113@mx.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 27, 2008 at 10:38:44PM +0100, Hannes Eder wrote:
> The sparse warning -Wreturn-void ("returning void-valued expression")
> is off by default, but it is enabled with -Wall, so add
> -Wno-return-void to CHECKFLAGS to disable it.
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>

Thanks Hannes - applied.

	Sam
