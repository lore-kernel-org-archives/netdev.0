From: Andrew Morton <akpm@osdl.org>
Subject: Re: -mm -> 2.6.13 merge status (dropped patches?)
Date: Thu, 30 Jun 2005 16:14:56 -0700
Message-ID: <20050630161456.2ef0ab32.akpm@osdl.org>
References: <200506301605_MC3-1-A320-D9D6@compuserve.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jgarzik@pobox.com,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S263109AbVF3XTF@vger.kernel.org>
To: Chuck Ebbert <76306.1226@compuserve.com>
In-Reply-To: <200506301605_MC3-1-A320-D9D6@compuserve.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chuck Ebbert <76306.1226@compuserve.com> wrote:
>
> On Mon, 20 Jun 2005 at 23:54:58 -0700, Andrew Morton wrote:
> 
> > This summarises my current thinking on various patches which are presently
> > in -mm.  I cover large things and small-but-controversial things.  Anything
> > which isn't covered here (and that's a lot of material) is probably a "will
> > merge", unless it obviously isn't.
> 
> What happened to:
> 
>         remove-last_rx-update-from-loopback-device.patch

Davem rejected it.  hm, I can't find the email trail - it was cc'ed to
netdev@oss.sgi.com mid-March, but nothing seems to have been sent back.

> It was dropped in 2.6.12-rc1-mm4 with a status of "merged" but it's not
> in either 2.6.12 or 2.6.13-rc1.
> 
> And in general, who is tracking whether things are being lost?

Things don't get lost.  I have a habit of misremembering the disposition of
patches when preparing -mm release summaries.
