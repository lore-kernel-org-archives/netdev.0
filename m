From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH v2 0/5] make POSIX timers optional with some Kconfig help
Date: Thu, 27 Oct 2016 01:52:19 +0200
Message-ID: <1477525939.2121.22.camel@tiscali.nl>
References: <1477448931-29051-1-git-send-email-nicolas.pitre@linaro.org>
         <1477523669.2121.8.camel@tiscali.nl>
         <alpine.LFD.2.20.1610261938410.14694@knanqh.ubzr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: John Stultz <john.stultz@linaro.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Michal Marek <mmarek@suse.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Josh Triplett <josh@joshtriplett.org>,
        Edward Cree <ecree@solarflare.com>, netdev@vger.kernel.org,
        linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lb3-smtp-cloud3.xs4all.net ([194.109.24.30]:56826 "EHLO
        lb3-smtp-cloud3.xs4all.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932584AbcJZXw1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 19:52:27 -0400
In-Reply-To: <alpine.LFD.2.20.1610261938410.14694@knanqh.ubzr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-10-26 at 19:41 -0400, Nicolas Pitre wrote:
> On Thu, 27 Oct 2016, Paul Bolle wrote:
> > If you'll have to send another update don't bother including Yann. Yann
> > hasn't be heard of in years. MAINTAINERS doesn't reflect reality for
> > kconfig.
> 
> What about updating it then?

I don't know why Yann is still mentioned after M: in MAINTAINERS. In
practice Michal has (again) been taking care of kconfig.


Paul Bolle
