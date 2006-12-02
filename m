From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 2.6.18] declance: Support the I/O ASIC LANCE w/o
 TURBOchannel
Date: Fri, 1 Dec 2006 21:46:26 -0800
Message-ID: <20061201214626.1c50dd38.akpm@osdl.org>
References: <Pine.LNX.4.64N.0611301306460.1757@blysk.ds.pg.gda.pl>
	<45710CFE.5090007@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Maciej W. Rozycki" <macro@linux-mips.org>, netdev@vger.kernel.org,
	linux-mips@linux-mips.org
Return-path: <linux-mips-bounce@linux-mips.org>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <45710CFE.5090007@pobox.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

On Sat, 02 Dec 2006 00:19:58 -0500
Jeff Garzik <jgarzik@pobox.com> wrote:

> Maciej W. Rozycki wrote:
> >  The onboard LANCE of I/O ASIC systems is not a TURBOchannel device, at 
> > least from the software point of view.  Therefore it does not rely on any 
> > kernel TURBOchannel bus services and can be supported even if support for 
> > TURBOchannel has not been enabled in the configuration.
> > 
> > Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
> 
> can you (or Andrew) please resend your patches against 2.6.19?
> 

I have then all (I think) queued up.  Will send once I've done a round
of build-testing.
