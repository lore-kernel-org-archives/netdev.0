From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: keyboard dead with 45b5035
Date: Mon, 18 Feb 2008 20:50:01 +0100
Message-ID: <200802182050.01964.rjw@sisk.pl>
References: <20080218185305.48a67587@mjolnir.drzeus.cx>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Laszlo Attila Toth <panther@balabit.hu>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Pierre Ossman <drzeus-list@drzeus.cx>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760814AbYBRTwA@vger.kernel.org>
In-Reply-To: <20080218185305.48a67587@mjolnir.drzeus.cx>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, 18 of February 2008, Pierre Ossman wrote:
> The patch "[RTNETLINK]: Send a single notification on device state changes." kills (at least)
> the keyboard here. Everything seems to work fine in single user mode, but when init starts
> spawning of logins, the keyboard goes bye-bye. Even the power button is ignored. :/ 

Please try with the patch from http://lkml.org/lkml/2008/2/18/331 .

Thanks,
Rafael
