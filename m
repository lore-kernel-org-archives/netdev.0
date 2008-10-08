From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: Top kernel oopses/warnings for the week of October 7th, 2008
Date: Wed, 8 Oct 2008 11:06:54 +0200
Message-ID: <200810081106.55730.rjw@sisk.pl>
References: <48EBBE15.9030905@linux.intel.com> <20081007235833.1a89948f@lxorguk.ukuu.org.uk> <20081007.160835.257227518.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, arjan@linux.intel.com,
	linux-kernel@vger.kernel.org, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, mingo@elte.hu, netdev@vger.kernel.org,
	linux-acpi@vger.kernel.org, tglx@tglx.de, tytso@mit.edu,
	linux-ide@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-ide-owner@vger.kernel.org>
In-Reply-To: <20081007.160835.257227518.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, 8 of October 2008, David Miller wrote:
> From: Alan Cox <alan@lxorguk.ukuu.org.uk>
> Date: Tue, 7 Oct 2008 23:58:33 +0100
> 
> > > This should have been fixed by:
> > > http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=f5a6d958b5d0a10e7e7a9dee1862fb31d08c6d26
> > 
> > You mean - hidden by - that change should IMHO be reverted
> 
> Grrr... I totally agree.

Even though they are false positives in many cases?

(Yes, they are).
