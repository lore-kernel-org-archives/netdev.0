From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 0/4] make POSIX timers optional with some Kconfig help
Date: Thu, 20 Oct 2016 11:46:57 +0200 (CEST)
Message-ID: <alpine.DEB.2.20.1610201145310.5073@nanos>
References: <1476920573-14384-1-git-send-email-nicolas.pitre@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: John Stultz <john.stultz@linaro.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Yann E MORIN <yann.morin.1998@free.fr>,
        Josh Triplett <josh@joshtriplett.org>, netdev@vger.kernel.org,
        linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <1476920573-14384-1-git-send-email-nicolas.pitre@linaro.org>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 19 Oct 2016, Nicolas Pitre wrote:
> Therefore this series also includes kconfig changes to implement a new
> keyword to express some reverse dependencies like "select" does, named
> "imply", and still allowing for the target config symbol to be disabled
> if the user or a direct dependency says so.

That's really nice work! Thanks for doing that. It makes the whole thing
more palatable.

Thanks,

	tglx
