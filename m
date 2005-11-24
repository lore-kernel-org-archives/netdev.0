From: Dmitry Torokhov <dtor_core@ameritech.net>
Subject: Re: Mouse issues in -mm
Date: Wed, 23 Nov 2005 22:26:43 -0500
Message-ID: <200511232226.44459.dtor_core@ameritech.net>
References: <20051123033550.00d6a6e8.akpm@osdl.org> <20051123113854.07fca702.akpm@osdl.org> <4385202E.70404@tuxrocks.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>,
	Marc Koschewski <marc@osknowledge.org>,
	linux-kernel@vger.kernel.org, Harald Welte <laforge@netfilter.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932591AbVKXD0w@vger.kernel.org>
To: Frank Sorenson <frank@tuxrocks.com>
In-Reply-To: <4385202E.70404@tuxrocks.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 23 November 2005 21:06, Frank Sorenson wrote:
> Andrew Morton wrote:
> > Marc Koschewski <marc@osknowledge.org> wrote:
> >>Just booted into 2.6.15-rc2-mm1. The 'mouse problem' (as reported earlier) still
> >>persists,
> >
> > You'l probably need to re-report the mouse problem if the previous report
> > didn't get any action.
> 
> I'm not certain whether this is the same 'mouse problem', but I'll
> report the mouse problems I've been seeing.  In the past several -mm
> kernels, my touchpad has initially worked at boot, but 'tapping' has
> stopped working at some point later (with no obvious kernel messages).
> 
> I've experienced this problem at least with 2.6.15-rc1-mm2 and
> 2.6.15-rc2-mm1, and reverting
> input-attempt-to-re-synchronize-mouse-every-5-seconds.patch gives a
> kernel without the touchpad problems.
>

What kind of touchpad do you have? Could you post your
/pros/bus/input/devices please?

-- 
Dmitry
