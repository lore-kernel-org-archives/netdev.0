From: Tomasz Torcz <zdzichu@irc.pl>
Subject: Re: [Prism54-devel] Re: TxDescriptors -> 1024 default. Please not for every NIC!
Date: Thu, 20 May 2004 18:45:16 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040520164516.GA9913@irc.pl>
References: <OF72607111.CD0234C8-ON85256DA1.0068861B-86256DA1.0068FF60@us.ibm.com> <Pine.LNX.4.58.0405151354220.9894@fcat> <Pine.LNX.4.58.0405190256010.30653@fcat> <20040519102700.GA16465@ee.oulu.fi> <20040520141111.GR13898@ruslug.rutgers.edu> <20040520163811.GA15832@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040520163811.GA15832@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 20, 2004 at 09:38:11AM -0700, Jean Tourrilhes wrote:
> 	I personally would stick with 100. The IrDA stack runs
> perfectly fine with 15 buffers at 4 Mb/s. If 100 is not enough, I
> think the problem is not the number of buffers, but somewhere else.

 I don't know how much trollish or true is that comment:
http://bsd.slashdot.org/comments.pl?sid=106258&cid=9049422
but it suggest, that Linux' stack having no BSD like mbuf functionality,
is not perfect for fast transmission. Maybe some network guru
cna comment ?

-- 
Tomasz Torcz       ,,(...) today's high-end is tomorrow's embedded processor.''
zdzichu@irc.-nie.spam-.pl                      -- Mitchell Blank on LKML
