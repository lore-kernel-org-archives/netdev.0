From: Grant Grundler <grundler@chromium.org>
Subject: Re: [PATCH 4/4] asix: Add a new driver for the AX88172A
Date: Thu, 12 Jul 2012 16:10:04 -0700
Message-ID: <CANEJEGsvBbPYk4_W1jmFzSGu8cQ2VGAEyj9vyPBLrBYDO5_gfQ@mail.gmail.com>
References: <1341574388-7464-1-git-send-email-christian.riesch@omicron.at>
	<1341574388-7464-5-git-send-email-christian.riesch@omicron.at>
	<CANEJEGu3iTDYJD+ZpcwgRCZTF8a_bi9kWSuKK4eaHzS1uL+ZxA@mail.gmail.com>
	<CABkLObon+CkLJagu2pX0OBGpNzSn9NfyM353h2BQ68viy2Bq6Q@mail.gmail.com>
	<CABkLObpRNpcEjFYaUUEjnEWN-8snQZaa27+CCO7pHnR7kPVMUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Oliver Neukum <oneukum@suse.de>,
	Eric Dumazet <edumazet@google.com>,
	Allan Chou <allan@asix.com.tw>,
	Mark Lord <kernel@teksavvy.com>,
	Ming Lei <tom.leiming@gmail.com>,
	Michael Riesch <michael@riesch.at>
To: Christian Riesch <christian.riesch@omicron.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:35894 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964858Ab2GLXKF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 19:10:05 -0400
Received: by qadb17 with SMTP id b17so18301qad.19
        for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 16:10:04 -0700 (PDT)
In-Reply-To: <CABkLObpRNpcEjFYaUUEjnEWN-8snQZaa27+CCO7pHnR7kPVMUg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 12, 2012 at 12:22 AM, Christian Riesch
<christian.riesch@omicron.at> wrote:
> Hi Grant,
...
> After rethinking it I decided to keep the switch structure, but use
> defines for the different modes and the bitmask. I think this will be
> easier to understand. I will submit a new version of the patchset
> later today, please have a look at it.

That's fine too. I agree the new version is easier to read.

thanks!
grant

> Thanks!
> Christian
