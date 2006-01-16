From: Samuel Ortiz <samuel.ortiz@nokia.com>
Subject: Re: wireless: recap of current issues (configuration)
Date: Mon, 16 Jan 2006 22:10:51 +0200 (EET)
Message-ID: <Pine.LNX.4.58.0601162204240.17348@irie>
References: <20060113212605.GD16166@tuxdriver.com> <20060113213011.GE16166@tuxdriver.com>
 <20060113221935.GJ16166@tuxdriver.com> <1137191522.2520.63.camel@localhost>
 <20060114011726.GA19950@shaftnet.org> <43C97605.9030907@pobox.com>
 <20060115152034.GA1722@shaftnet.org> <43CAA853.8020409@errno.com>
 <20060116172817.GB8596@shaftnet.org> <Pine.LNX.4.58.0601162056261.17348@irie>
 <20060116195008.GB12748@shaftnet.org>
Reply-To: samuel.ortiz@nokia.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Sam Leffler <sam@errno.com>, Jeff Garzik <jgarzik@pobox.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751185AbWAPUNU@vger.kernel.org>
To: ext Stuffed Crust <pizza@shaftnet.org>
In-Reply-To: <20060116195008.GB12748@shaftnet.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 16 Jan 2006, ext Stuffed Crust wrote:

> You may hear another beacon when the STA is awake, you may not.  BSSID
> filtering has nothing to do with 802.11 power save, but rather is
> intented to reduce the host load (interrupts, processing overhead) and
> thus the host power consumption.
I know that and I know a bit about 802.11 PS as well.
I was talking about host powersaving, not 802.11. Sorry for the confusion.

What I meant is that having an 802.11 stack capable of living with less
than a beacon every couple of beacon intervals would be nice as well.

Cheers,
Samuel.
