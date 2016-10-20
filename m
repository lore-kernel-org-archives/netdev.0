From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH 0/4] make POSIX timers optional with some Kconfig help
Date: Thu, 20 Oct 2016 14:35:59 -0400 (EDT)
Message-ID: <alpine.LFD.2.20.1610201433250.25105@knanqh.ubzr>
References: <1476920573-14384-1-git-send-email-nicolas.pitre@linaro.org> <alpine.DEB.2.20.1610201145310.5073@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: John Stultz <john.stultz@linaro.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Yann E MORIN <yann.morin.1998@free.fr>,
        Josh Triplett <josh@joshtriplett.org>, netdev@vger.kernel.org,
        linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.20.1610201145310.5073@nanos>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 20 Oct 2016, Thomas Gleixner wrote:

> On Wed, 19 Oct 2016, Nicolas Pitre wrote:
> > Therefore this series also includes kconfig changes to implement a new
> > keyword to express some reverse dependencies like "select" does, named
> > "imply", and still allowing for the target config symbol to be disabled
> > if the user or a direct dependency says so.
> 
> That's really nice work! Thanks for doing that. It makes the whole thing
> more palatable.

Thanks.

Now I'd need some review tags...  ;-)


Nicolas
