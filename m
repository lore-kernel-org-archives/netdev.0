From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: Regression: Wireshark sees no packets in 2.6.24-rc3
Date: Sat, 15 Dec 2007 03:05:02 +0100
Message-ID: <200712150305.02589.rjw@sisk.pl>
References: <2c0942db0712131746s7da91f2bkf45b3e1ddf16d1f3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: "Ray Lee" <ray@madrabbit.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:42822 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751658AbXLOBqF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2007 20:46:05 -0500
In-Reply-To: <2c0942db0712131746s7da91f2bkf45b3e1ddf16d1f3@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, 14 of December 2007, Ray Lee wrote:
> tshark -i eth0, eth1, lo are all empty. Works under 2.6.23.0 just
> fine. A quick scan of the log between 2.6.24-rc3 and current tip
> (-rc5) doesn't show any obvious fixes, but then again, what do I know.
> I'll check current tip on the weekend when I'll have the luxury to
> have my main system down long enough for a test. Right now I'm kinda
> up against a deadline, but didn't want to leave it unreported. Should
> be easy for someone else to confirm or deny whether current tip has
> the problem.

FYI, I have created a bugzilla entry for this issue at:
http://bugzilla.kernel.org/show_bug.cgi?id=9568

Thanks,
Rafael
