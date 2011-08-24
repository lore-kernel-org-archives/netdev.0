From: Guan Xuetao <gxt@mprc.pku.edu.cn>
Subject: Re: linux-next: manual merge of the net tree with the unicore32
 tree
Date: Wed, 24 Aug 2011 09:28:42 +0800
Message-ID: <1314149322.29738.14.camel@epip-laptop>
References: <20110823130210.766d466d689d60536f59340a@canb.auug.org.au>
	 <1314090049.2128.224.camel@jtkirshe-mobl>
Reply-To: gxt@mprc.pku.edu.cn
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Zhang Shu <davidshuzhang@gmail.com>,
	Chu Xiaowei <chuxiaowei@mprc.pku.edu.cn>,
	Su Yonggang <tonyhook.su@gmail.com>
To: jeffrey.t.kirsher@intel.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1314090049.2128.224.camel@jtkirshe-mobl>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-08-23 at 02:00 -0700, Jeff Kirsher wrote:
> On Mon, 2011-08-22 at 20:02 -0700, Stephen Rothwell wrote:
> > Hi all,
> > 
> > Today's linux-next merge of the net tree got conflicts in
> > drivers/net/Kconfig and drivers/net/Makefile between commit
> > e8787de6fa83
> > ("unicore32: add pkunity-v3 mac/net driver (umal)") from the unicore32
> > tree and the network driver rearrangement from the net tree.
> > 
> > I just added the new driver from the unicore32 tree commit into each
> > file
> > (see below).
> > -- 
> > Cheers,
> > Stephen Rothwell                    sfr@canb.auug.org.au 
> 
> Hmm, well with the latest series of patches I sent out, I am pretty sure
> this patch would not apply.
Ok, I see.
Thanks Jeff, and thanks Stephen.

Guan Xuetao

> 
> Is it best that this patch not be sent to netdev for driver
> inclusion? :)
