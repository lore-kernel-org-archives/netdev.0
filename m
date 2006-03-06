From: Martin Michlmayr <tbm@cyrius.com>
Subject: Re: de2104x: interrupts before interrupt handler is registered
Date: Mon, 6 Mar 2006 20:29:07 +0000
Message-ID: <20060306202907.GB8747@deprecation.cyrius.com>
References: <20060305180757.GA22121@deprecation.cyrius.com> <20060305185948.GA24765@electric-eye.fr.zoreil.com> <20060306143512.GI23669@deprecation.cyrius.com> <20060306191706.GA6947@deprecation.cyrius.com> <20060306194821.GA15728@electric-eye.fr.zoreil.com> <20060306195953.GB10703@deprecation.cyrius.com> <20060306202330.GB15728@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751629AbWCFU3V@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20060306202330.GB15728@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Francois Romieu <romieu@fr.zoreil.com> [2006-03-06 21:23]:
> > http://www.cyrius.com/tmp/config-2.6.16-rc5-486
> > By the way, I'm getting the following messages in dmesg:
> netconsole appears enabled. Do you use it ?

It's a standard Debian kernel config so pretty much everything is
enabled as a module.  I didn't use netconsole.
-- 
Martin Michlmayr
http://www.cyrius.com/
