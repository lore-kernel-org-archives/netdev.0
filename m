From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 driver in 2.6.6
Date: Thu, 27 May 2004 09:25:36 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040527092536.A15669@electric-eye.fr.zoreil.com>
References: <20040525230831.4747005f.ray_cole@earthlink.net> <20040525231140.1325daa7.ray_cole@earthlink.net> <20040526055841.GH3330@ruslug.rutgers.edu> <20040526133645.B32639@electric-eye.fr.zoreil.com> <20040526070014.17ee9486.ray_cole@earthlink.net> <20040526161508.A3368@electric-eye.fr.zoreil.com> <20040526191528.54f4af59.ray_cole@earthlink.net> <20040526205324.0913df99.ray_cole@earthlink.net> <20040526221742.393e626d.ray_cole@earthlink.net> <20040526230632.26c4e2e5.ray_cole@earthlink.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ray Cole <ray_cole@earthlink.net>
Content-Disposition: inline
In-Reply-To: <20040526230632.26c4e2e5.ray_cole@earthlink.net>; from ray_cole@earthlink.net on Wed, May 26, 2004 at 11:06:32PM -0500
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ray Cole <ray_cole@earthlink.net> :
> It looks like it is most definately a gcc 2.95.3 issue.  I turned off
> optimization (appended -O0 to the compiler command line) and the 'bad' way
> gives the proper result.  -O1, on the other hand, gives an incorrect result.

Would you be kind enough to send the two versions of the 2.6.6 r8169.o
files compiled with 2.95.3: the unmodified one and the one with your
minimal workaround ?

--
Ueimor
