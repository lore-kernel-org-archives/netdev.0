From: Roy Sigurd Karlsbakk <roy@karlsbakk.net>
Subject: Re: sendfile64() anyone? (was [RESEND] tuning linux for high network performance?)
Date: Thu, 24 Oct 2002 13:07:36 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200210241307.36134.roy@karlsbakk.net>
References: <200210231218.18733.roy@karlsbakk.net> <200210241230.46848.roy@karlsbakk.net> <1035456463.10555.7.camel@rth.ninka.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: bert hubert <ahu@ds9a.nl>, netdev@oss.sgi.com,
   Kernel mailing list <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@rth.ninka.net>
In-Reply-To: <1035456463.10555.7.camel@rth.ninka.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thursday 24 October 2002 12:47, David S. Miller wrote:
> On Thu, 2002-10-24 at 03:30, Roy Sigurd Karlsbakk wrote:
> > Are there any plans of implementing sendfile64() or sendfile() support
> > for -D_FILE_OFFSET_BITS=64?
>
> This is old hat, and appears in every current vendor kernel I am
> aware of and is in 2.5.x as well.

then where can I find these patches? I cannot use 2.5, and I usually try to 
stick with an official kernel.

and - if this patch has been around all this time...

	why isn't it in the official kernel yet?

-- 
Roy Sigurd Karlsbakk, Datavaktmester
ProntoTV AS - http://www.pronto.tv/
Tel: +47 9801 3356

Computers are like air conditioners.
They stop working when you open Windows.
