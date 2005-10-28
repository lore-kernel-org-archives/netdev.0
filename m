From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 02/14] Big kfree NULL check cleanup - drivers/net
Date: Fri, 28 Oct 2005 16:53:31 -0400
Message-ID: <43628FCB.9060202@pobox.com>
References: <200510132122.48035.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
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
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751701AbVJ1Uxq@vger.kernel.org>
To: Jesper Juhl <jesper.juhl@gmail.com>
In-Reply-To: <200510132122.48035.jesper.juhl@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesper Juhl wrote:
> This is the drivers/net/ part of the big kfree cleanup patch.
> 
> Remove pointless checks for NULL prior to calling kfree() in drivers/net/.
> 
> 
> Sorry about the long Cc: list, but I wanted to make sure I included everyone
> who's code I've changed with this patch.
> 
> 
> Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>

applied 98% of this
