From: Lee Revell <rlrevell@joe-job.com>
Subject: Re: [0/3] via-rhine: experimental patches
Date: Mon, 09 Aug 2004 22:08:14 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1092103694.761.5.camel@mindpipe>
References: <20040808140216.GA8181@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com,
        linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Roger Luethi <rl@hellgate.ch>
In-Reply-To: <20040808140216.GA8181@k3.hellgate.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2004-08-08 at 10:02, Roger Luethi wrote:
> The following batch needs testing. I don't expect any notable
> regressions, but I could do with some reports on WOL (already in -mm)
> and suspend/resume.
> 

Maybe this is a known issue by now, but the via-rhine bug is still not
fixed in 2.6.8-rc3.  I had to replace it with the via-rhine.c from -mm2
to get online.

Lee
