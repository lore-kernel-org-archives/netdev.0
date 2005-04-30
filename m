From: Olivier Galibert <galibert@pobox.com>
Subject: Re: [2.6 patch] drivers/net/hamradio/baycom_epp.c: cleanups
Date: Sat, 30 Apr 2005 20:21:20 +0200
Message-ID: <20050430182120.GB41358@dspnet.fr.eu.org>
References: <20050430181529.GF3571@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, sailer@ife.ee.ethz.ch,
        linux-kernel@vger.kernel.org, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20050430181529.GF3571@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Apr 30, 2005 at 08:15:30PM +0200, Adrian Bunk wrote:
> The times when tricky goto's produced better codes are long gone.
> 
> This patch should express the same in a better way, please check whether 
> I made any mistake.

Stupid question I'm sure, but did you bench it?

  OG.
