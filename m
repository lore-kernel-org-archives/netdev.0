From: "David S. Miller" <davem@rth.ninka.net>
Subject: Re: sendfile64() anyone? (was [RESEND] tuning linux for high
	network performance?)
Date: 24 Oct 2002 03:47:43 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1035456463.10555.7.camel@rth.ninka.net>
References: <200210231218.18733.roy@karlsbakk.net>
	<200210231542.48673.roy@karlsbakk.net>
	<1035432669.9628.1.camel@rth.ninka.net>
	<200210241230.46848.roy@karlsbakk.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: bert hubert <ahu@ds9a.nl>, netdev@oss.sgi.com,
   Kernel mailing list
	 <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Roy Sigurd Karlsbakk <roy@karlsbakk.net>
In-Reply-To: <200210241230.46848.roy@karlsbakk.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2002-10-24 at 03:30, Roy Sigurd Karlsbakk wrote:
> Are there any plans of implementing sendfile64() or sendfile() support for 
> -D_FILE_OFFSET_BITS=64?

This is old hat, and appears in every current vendor kernel I am
aware of and is in 2.5.x as well.
