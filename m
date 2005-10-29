From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: Re: [PATCH 02/14] Big kfree NULL check cleanup - drivers/net
Date: Sat, 29 Oct 2005 15:56:31 +0200
Message-ID: <9a8748490510290656v3227bd5bl144baee8faa398dc@mail.gmail.com>
References: <200510132122.48035.jesper.juhl@gmail.com>
	 <43628FCB.9060202@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jes Sorensen <jes@trained-monkey.org>,
	Matt Porter <mporter@kernel.crashing.org>,
	Michael Chan <mchan@broadcom.com>, linux.nics@intel.com,
	hans@esrac.ele.tue.nl, Santiago Leon <santil@us.ibm.com>,
	Jean Tourrilhes <jt@hpl.hp.com>,
	Paul Mackerras <paulus@samba.org>,
	Michael Hipp <hippm@informatik.uni-tuebingen.de>,
	Jes Sorensen <jes@wildopensource.com>,
	Carsten Langgaard <carstenl@mips.com>,
	Benjamin Reed <breed@users.sourceforge.net>,
	Jouni Malinen <jkmaline@cc.hut.fi>,
	prism54-private@prism54.org, netdev@vger.kernel.org,
	Stuart Cheshire <cheshire@cs.stanford.edu>,
	g4klx@g4klx.demon.co.uk, Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751056AbVJ2N5E@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <43628FCB.9060202@pobox.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/28/05, Jeff Garzik <jgarzik@pobox.com> wrote:
> Jesper Juhl wrote:
> > This is the drivers/net/ part of the big kfree cleanup patch.
> >
> > Remove pointless checks for NULL prior to calling kfree() in drivers/net/.
> >
> >
> > Sorry about the long Cc: list, but I wanted to make sure I included everyone
> > who's code I've changed with this patch.
> >
> >
> > Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
>
> applied 98% of this
>

Just currious, what bits are the 2% you did not apply?

--
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html
