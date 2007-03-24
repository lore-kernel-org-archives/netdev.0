From: David Miller <davem@davemloft.net>
Subject: Re: [NET] AX.25 Kconfig and docs updates and fixes
Date: Sat, 24 Mar 2007 12:54:36 -0700 (PDT)
Message-ID: <20070324.125436.115921208.davem@davemloft.net>
References: <20070313115537.GA10921@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-hams@vger.kernel.org, netdev@vger.kernel.org
To: ralf@linux-mips.org
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20070313115537.GA10921@linux-mips.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Tue, 13 Mar 2007 11:55:38 +0000

>  o The AX.25 Howto is unmaintained since several years.  I've replaced it
>    with a wiki at http://www.linux-ax25.org which provides more uptodate
>    information.
>  o Change default for AX25_DAMA_SLAVE to Y.  AX25_DAMA_SLAVE only compiles
>    in support for DAMA but doesn't activate it.  I hope this gets Linux
>    distributions to ship their AX.25 kernels with AX25_DAMA_SLAVE enabled.
>    The price for this would be very small.
>  o Delete historic changelog from comments, that's what SCM systems are
>    meant to do.
>  o ---help--- in Kconfig looks so yellingly eye insulting.  Use just help.
>  o Rewrite the commented out piece of old Linux 2.4 configuration language
>    to Kconfig for consistency.
>  o Fixup dependencies.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

Applied, thanks Ralf.
