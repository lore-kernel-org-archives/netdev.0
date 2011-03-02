From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 0/7] Final BKL removal, take 2
Date: Wed, 2 Mar 2011 22:54:09 +0100
Message-ID: <201103022254.10078.arnd@arndb.de>
References: <1299021191-17961-1-git-send-email-arnd@arndb.de> <20110302140428.GA630@suse.de> <4D6EA965.9050709@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Greg KH <gregkh@suse.de>, linux-kernel@vger.kernel.org,
	Andi Kleen <ak@linux.intel.com>,
	Andrew Hendry <andrew.hendry@gmail.com>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Evgeniy Dushistov <dushistov@mail.ru>,
	linux-fsdevel@vger.kernel.org, linux-x25@vger.kernel.org,
	Max Vozeler <max@vozeler.com>,
	Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>,
	netdev@vger.kernel.org, Nick Bowler <nbowler@elliptictech.com>,
	Nick Piggin <npiggin@gmail.com>,
	Palash Bandyopadhyay <palash.bandyopadhyay@conexant.com>,
	Takahiro Hirofuchi <hirofuchi@users.sourceforge.net>
To: Mauro Carvalho Chehab <mchehab@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D6EA965.9050709@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 02 March 2011 21:32:37 Mauro Carvalho Chehab wrote:
> >>
> >> It is probably better to queue the staging/cx25821 patch via my tree, as this is one
> >> of those staging files that it is handled via media tree. So, if it is ok
> >> for you both, I'll get patch 2/7.
> > 
> > Yes, you are right, please take it through your tree.
> 
> Patch applied on my tree, thanks!

I've pushed out everything to my git tree, except for the two staging
patches that go through the other trees.

Once everything is in -next, I'll add the last patch to remove the
infrastructure.

Thanks for the feedback!

	Arnd
