From: Lee Revell <rlrevell@joe-job.com>
Subject: Re: [0/3] via-rhine: experimental patches
Date: Tue, 10 Aug 2004 03:16:08 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1092122167.829.7.camel@mindpipe>
References: <20040808140216.GA8181@k3.hellgate.ch>
	 <1092103694.761.5.camel@mindpipe>  <20040810071050.GC11224@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com,
        linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Roger Luethi <rl@hellgate.ch>
In-Reply-To: <20040810071050.GC11224@k3.hellgate.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-08-10 at 03:10, Roger Luethi wrote:
> On Mon, 09 Aug 2004 22:08:14 -0400, Lee Revell wrote:
> > On Sun, 2004-08-08 at 10:02, Roger Luethi wrote:
> > > The following batch needs testing. I don't expect any notable
> > > regressions, but I could do with some reports on WOL (already in -mm)
> > > and suspend/resume.
> > 
> > Maybe this is a known issue by now, but the via-rhine bug is still not
> > fixed in 2.6.8-rc3.  I had to replace it with the via-rhine.c from -mm2
> > to get online.
> 
> It is known. The fix for that bug is simmering in the pipeline
> somewhere. The experimental patches OTOH were for -mm and unrelated.
> 

OK, just wanted to make sure the fix gets into 2.6.8, because it can be
a showstopper.

Lee
