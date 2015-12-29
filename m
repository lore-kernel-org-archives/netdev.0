From: Heiko =?ISO-8859-1?Q?St=FCbner?= <heiko@sntech.de>
Subject: Re: [RESEND PATCH v1 0/4] Add support emac for the RK3036 SoC platform
Date: Tue, 29 Dec 2015 23:27:55 +0100
Message-ID: <3925713.yDzK1dvrIv@diego>
References: <1451287341-16453-1-git-send-email-zhengxing@rock-chips.com> <20151229.155314.1522114236952280828.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: zhengxing@rock-chips.com, linux-rockchip@lists.infradead.org,
	keescook@google.com, leozwang@google.comi, linux@arm.linux.org.uk,
	devicetree@vger.kernel.org, netdev@vger.kernel.org,
	paul.gortmaker@windriver.com, galak@codeaurora.org,
	linux-kernel@vger.kernel.org, ijc+devicetree@hellion.org.uk,
	pawel.moll@arm.com, geert@linux-m68k.org, mark.rutland@arm.com,
	robh+dt@kernel.org, linux-arm-kernel@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151229.155314.1522114236952280828.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

Am Dienstag, 29. Dezember 2015, 15:53:14 schrieb David Miller:
> You have to submit this series properly, the same problem happend twice
> now.
> 
> When you submit a series you should:
> 
> 1) Make it clear which tree you expect these changes to be applied
>    to.  Here it is completely ambiguous, do you want it to go into
>    my networking tree or some other subsystem tree?
> 
> 2) You MUST keep all parties informed about all patches for a series
>    like this.  That means you cannot drop netdev from patch #4 as
>    you did both times.  Doing this aggravates the situation for
>    #1 even more, because if a patch is not CC:'d to netdev it does
>    not enter patchwork.  And if it doesn't go into patchwork, I'm
>    not looking at it.

I guess that is some unfortunate result of git send-email combined with 
get_maintainer.pl . In general I also prefer to see the whole series, but have 
gotten such partial series from other maintainers as well in the past, so it 
seems to be depending on preferences somewhat.

For the series at hand, the 4th patch is the devicetree addition, which the 
expected way is me picking it up, after you are comfortable with the code-
related changes.


Heiko
