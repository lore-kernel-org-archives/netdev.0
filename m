From: "Ray Lee" <ray@madrabbit.org>
Subject: Re: Regression: Wireshark sees no packets in 2.6.24-rc3
Date: Sat, 15 Dec 2007 00:16:34 -0800
Message-ID: <2c0942db0712150016r149d285bs8f4e1c444e71afea@mail.gmail.com>
References: <2c0942db0712131746s7da91f2bkf45b3e1ddf16d1f3@mail.gmail.com>
	 <200712150305.02589.rjw@sisk.pl> <47633ECC.3020804@googlemail.com>
	 <2c0942db0712142309v15f79068m8c033180d41b9be@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: "Gabriel C" <nix.or.die@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hu-out-0506.google.com ([72.14.214.236]:36964 "EHLO
	hu-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751961AbXLOIQg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Dec 2007 03:16:36 -0500
Received: by hu-out-0506.google.com with SMTP id 19so567671hue.21
        for <netdev@vger.kernel.org>; Sat, 15 Dec 2007 00:16:34 -0800 (PST)
In-Reply-To: <2c0942db0712142309v15f79068m8c033180d41b9be@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Dec 14, 2007 11:09 PM, Ray Lee <ray@madrabbit.org> wrote:
> On Dec 14, 2007 6:41 PM, Gabriel C <nix.or.die@googlemail.com> wrote:
> Correct, absolutely no traffic. So if it works for you, then either
> it's something that got fixed between -rc3 and -rc5, or something odd
> when I did a make oldconfig, I suppose. (Or because I'm on an x86-64
> kernel?) Regardless, -rc5 is currently building, and I'll try it in
> the morning.

-rc5 works great. Really don't know what's different between my -rc3
and -rc5 builds. The diff of .config between the two doesn't show
anything obvious, so perhaps it was something fixed in the interim.

I've gone ahead and closed the bugzilla entry, btw. Thanks, and sorry
for the false (or tardy) alarm.

Ray
