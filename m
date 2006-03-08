From: Martin Michlmayr <tbm@cyrius.com>
Subject: Re: de2104x: interrupts before interrupt handler is registered
Date: Wed, 8 Mar 2006 03:22:19 +0000
Message-ID: <20060308032219.GD8094@deprecation.cyrius.com>
References: <20060305180757.GA22121@deprecation.cyrius.com> <20060305185948.GA24765@electric-eye.fr.zoreil.com> <20060306143512.GI23669@deprecation.cyrius.com> <20060306191706.GA6947@deprecation.cyrius.com> <20060306211745.GD15728@electric-eye.fr.zoreil.com> <20060307051152.GA1244@deprecation.cyrius.com> <20060308001556.GA9362@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932425AbWCHDWe@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20060308001556.GA9362@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Francois Romieu <romieu@fr.zoreil.com> [2006-03-08 01:15]:
> netdev watchdog events appear in the dmesg of the patched driver.
> The driver survived it. So I'd say that the patch does its job.
> 
> OTOH, if you ever saw the unpatched driver survive this event, yell
> now.

No, I've never seen the unpatched driver survive.
-- 
Martin Michlmayr
http://www.cyrius.com/
