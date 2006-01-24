From: Mattia Dongili <malattia@linux.it>
Subject: Re: e100 oops on resume
Date: Wed, 25 Jan 2006 00:21:42 +0100
Message-ID: <20060124232142.GB6174@inferi.kami.home>
References: <20060124225919.GC12566@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750831AbWAXXVX@vger.kernel.org>
To: Stefan Seyfried <seife@suse.de>
Content-Disposition: inline
In-Reply-To: <20060124225919.GC12566@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 24, 2006 at 11:59:19PM +0100, Stefan Seyfried wrote:
> Hi,
> since 2.6.16rc1-git3, e100 dies on resume (regardless if from disk, ram or
> runtime powermanagement). Unfortunately i only have a bad photo of
> the oops right now, it is available from
> https://bugzilla.novell.com/attachment.cgi?id=64761&action=view
> I have reproduced this on a second e100 machine and can get a serial
> console log from this machine tomorrow if needed.
> It did resume fine with 2.6.15-git12

I experienced the same today, I was planning to get a photo tomorrow :)
I'm running 2.6.16-rc1-mm2 and the last working kernel was 2.6.15-mm4
(didn't try .16-rc1-mm1 being scared of the reiserfs breakage).

-- 
mattia
:wq!
