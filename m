From: Pavel Machek <pavel@suse.cz>
Subject: Re: ipw2100 wireless driver
Date: Wed, 14 Jul 2004 15:42:27 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040714134227.GA8978@elf.ucw.cz>
References: <20040714114135.GA25175@elf.ucw.cz> <20040714131523.GA498@ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, kernel list <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S267384AbUGNNmt@vger.kernel.org>
To: Vojtech Pavlik <vojtech@suse.cz>
Content-Disposition: inline
In-Reply-To: <20040714131523.GA498@ucw.cz>
List-Id: netdev.vger.kernel.org

Hi!

> > What is the status of ipw2100? Is there chance that it would be pushed
> > into mainline?
> > 
> > I have few problems with that:
> > 
> > * it will not compile with gcc-2.95. Attached patch fixes one problem
> > but more remain.
> 
> Wouldn't "struct sk_buff **fragments" be a more correct fix?

Yep, that would certainly be better. I'll wait if I get some  reply
from ipw2100 people. If so I'll update the patch.
								Pavel
-- 
People were complaining that M$ turns users into beta-testers...
...jr ghea gurz vagb qrirybcref, naq gurl frrz gb yvxr vg gung jnl!
