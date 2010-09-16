From: Samuel Ortiz <samuel@sortiz.org>
Subject: Re: Remaining BKL users, what to do
Date: Thu, 16 Sep 2010 18:57:56 +0200
Message-ID: <1284656277.2962.0.camel@sortiz-mobl>
References: <201009161632.59210.arnd@arndb.de>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: codalist@coda.cs.cmu.edu, autofs@linux.kernel.org,
	linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org,
	Christoph Hellwig <hch@infradead.org>,
	Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Petr Vandrovec <vandrove@vc.cvut.cz>,
	Anders Larsen <al@alarsen.net>, Jan Kara <jack@suse.cz>,
	Evgeniy Dushistov <dushistov@mail.ru>,
	Ingo Molnar <mingo@elte.hu>, netdev@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Andrew Hendry <andrew.hendry@gmail.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201009161632.59210.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-09-16 at 16:32 +0200, Arnd Bergmann wrote:
> net/appletalk:
> net/ipx/af_ipx.c:
> net/irda/af_irda.c:
> 	Can probably be saved from retirement in drivers/staging if the
> 	maintainers still care.
I'll take care of the IrDA part.

Cheers,
Samuel.
