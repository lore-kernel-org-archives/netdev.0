From: Pavel Machek <pavel@ucw.cz>
Subject: Re: 2.6.34-rc1: bluetooth oops
Date: Thu, 25 Mar 2010 15:26:40 +0100
Message-ID: <20100325142640.GA1602@ucw.cz>
References: <20100314201434.GE22059@elf.ucw.cz> <1268598500.3897.36.camel@localhost.localdomain> <20100314204434.GB5208@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel list <linux-kernel@vger.kernel.org>,
	linux-bluetooth@vger.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>
To: Marcel Holtmann <marcel@holtmann.org>, netdev@vger.kernel.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100314204434.GB5208@elf.ucw.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun 2010-03-14 21:44:34, Pavel Machek wrote:
> Hi!
> 
> > > I got this after trying to use bnep for few minutes... Machine locked
> > > after that, not sure if it is related.
> > 
> > I can't explain it since we haven't changed the BNEP code. So that might
> > be a problem in the networking layer. So posting it to netdev might be a
> > good idea.
> 
> Ok, I'll try using bnep some more. I had bad problems with cellphone
> connection at that point, so maybe it is not easy to repeat, and it
> the fact I have not seen it before may not mean much...

So it seems to repeat about twice a week, definitely a regression :-(.

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
