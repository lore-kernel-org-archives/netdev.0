From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 driver in 2.6.6
Date: Wed, 26 May 2004 13:28:14 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040526132814.A32639@electric-eye.fr.zoreil.com>
References: <20040524210148.2172d684.ray_cole@earthlink.net> <20040525091915.A12162@electric-eye.fr.zoreil.com> <20040525230831.4747005f.ray_cole@earthlink.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ray Cole <ray_cole@earthlink.net>
Content-Disposition: inline
In-Reply-To: <20040525230831.4747005f.ray_cole@earthlink.net>; from ray_cole@earthlink.net on Tue, May 25, 2004 at 11:08:31PM -0500
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ray Cole <ray_cole@earthlink.net> :
[...]
> Once I changed this it started working great.  I picked up on this when
> I noticed it was only sending 64 packets then failing.  I looked for
> differences in the way 2.6.5 and 2.6.6 handled a full transmit ring and
> this line looked suspicious...I figure it is perhaps a difference in the
> compiler I'm using (2.95.3) vs what others using this module are
> using...perhaps?

I would not bet against it :o)

Can you:
- send me your 2.6.5 and vanilla 2.6.6 .o file compiled under 2.95.3 
- try 2.6.6 on a different compiler (2.95.2 excluded) ?

Thank you for the analysis.

--
Ueimor
