From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [patch] 2.6.5-rc2 - r8169 DAC
Date: Mon, 5 Apr 2004 19:38:45 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040405193845.A19650@electric-eye.fr.zoreil.com>
References: <253ea2a8f4.2a8f4253ea@email.bigpond.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, ak@suse.de
Return-path: <netdev-bounce@oss.sgi.com>
To: Srihari Vijayaraghavan <harisri@telstra.com>
Content-Disposition: inline
In-Reply-To: <253ea2a8f4.2a8f4253ea@email.bigpond.com>; from harisri@telstra.com on Mon, Apr 05, 2004 at 09:38:46AM +1000
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Srihari Vijayaraghavan <harisri@telstra.com> :
[...]
> With that patch 2.6.5-rc2 + r8169 DAC compiles and works fine.

Nice.

> There is one problem however: If I unplug and plug the cable it does not
> come back to online (even the LED on the card does not glow). I did not try
> reloading the driver, but a reboot does fix it :-( (later today I shall try
> reloading the driver). OTOH the vanilla 2.6.5-rc2 (or rc3) does not show
> this behaviour.

Reloading the driver is known to bring the device online again.The issue is
known but I had not understood it as a regression against vanilla kernel :o(
I'll see what can be done.

--
Ueimor
