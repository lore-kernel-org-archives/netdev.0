From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 2.6.9-rc3] 3c59x: reload EEPROM values at rmmod for
 needy cards
Date: Fri, 15 Oct 2004 14:12:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041015141250.3920ab2f.akpm@osdl.org>
References: <20040928145455.C12480@tuxdriver.com>
	<Pine.LNX.4.44.0409291253510.1746-100000@training.scyld.com>
	<20040930091407.A10417@tuxdriver.com>
	<20041007134601.B29517@tuxdriver.com>
	<20041008123955.E14378@tuxdriver.com>
	<4170260D.9010905@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        becker@scyld.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4170260D.9010905@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> wrote:
>
> John W. Linville wrote:
>  > Enable reload of EEPROM values in reset at rmmod for cards that need
>  > it, similar to old EEPROM_NORESET flag but in reverse.
>  > 
>  > Signed-of-by: John W. Linville <linville@tuxdriver.com>
> 
>  Andrew... ack/nak?

I queued it up.

>  Seems OK to me, provided that it chills out in -mm for a while for 
>  people to test.

Yes, it takes some time for problems in this area to be shaken out.
