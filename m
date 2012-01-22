From: Maciej Rutecki <maciej.rutecki@gmail.com>
Subject: Re: recvmsg sleeping from invalid context
Date: Sun, 22 Jan 2012 20:31:51 +0100
Message-ID: <201201222031.51116.maciej.rutecki@gmail.com>
References: <20120113182401.GA25885@redhat.com> <201201220854.59968.maciej.rutecki@gmail.com> <20120122.141006.530154674609252253.davem@davemloft.net>
Reply-To: maciej.rutecki@gmail.com
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120122.141006.530154674609252253.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On niedziela, 22 stycznia 2012 o 20:10:06 David Miller wrote:
> From: Maciej Rutecki <maciej.rutecki@gmail.com>
> Date: Sun, 22 Jan 2012 08:54:59 +0100
> 
> > I created a Bugzilla entry at
> > https://bugzilla.kernel.org/show_bug.cgi?id=42629
> > for your bug report, please add your address to the CC list in there,
> > thanks!
> 
> Please don't do this, none of the networking developers use bugzilla,
> we keep the discussion and analysis going here on netdev.

These entries are using for tracking regressions, for *all* kernel parts, 
without any exception. I see no reason to treat someone differently. If netdev 
provides any interface to tracking regressions, then show me it. But then why 
you do not use one common tool for all kernel?

Regards
-- 
Maciej Rutecki
http://www.mrutecki.pl
