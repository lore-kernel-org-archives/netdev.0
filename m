From: Tomas Szepe <szepe@pinerecords.com>
Subject: Re: ipw2100 wireless driver
Date: Wed, 14 Jul 2004 14:30:33 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040714123033.GB18364@louise.pinerecords.com>
References: <20040714114135.GA25175@elf.ucw.cz> <Pine.LNX.4.60.0407141947270.27995@boston.corp.fedex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Machek <pavel@ucw.cz>, netdev@oss.sgi.com,
	kernel list <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S267368AbUGNMaq@vger.kernel.org>
To: Jeff Chua <jeffchua@silk.corp.fedex.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.60.0407141947270.27995@boston.corp.fedex.com>
List-Id: netdev.vger.kernel.org

On Jul-14 2004, Wed, 19:48 +0800
Jeff Chua <jeffchua@silk.corp.fedex.com> wrote:

> >I have few problems with that:
> >
> >* it will not compile with gcc-2.95. Attached patch fixes one problem
> >but more remain.
> 
> I've given up hope on that. Don't think it'll ever compile on 2.95. I'm 
> using ndiswrapper and it works nicely.

I'd rather fiddle around with gcc versions than risk stack overflows
from running Windows drivers in Linux kernel space.

-- 
Tomas Szepe <szepe@pinerecords.com>
