From: Jeff Chua <jeffchua@silk.corp.fedex.com>
Subject: Re: ipw2100 wireless driver
Date: Wed, 14 Jul 2004 19:48:43 +0800 (SGT)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.60.0407141947270.27995@boston.corp.fedex.com>
References: <20040714114135.GA25175@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com, kernel list <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S267214AbUGNLvS@vger.kernel.org>
To: Pavel Machek <pavel@ucw.cz>
In-Reply-To: <20040714114135.GA25175@elf.ucw.cz>
List-Id: netdev.vger.kernel.org


On Wed, 14 Jul 2004, Pavel Machek wrote:

> Hi!
>
> What is the status of ipw2100? Is there chance that it would be pushed
> into mainline?
>
> I have few problems with that:
>
> * it will not compile with gcc-2.95. Attached patch fixes one problem
> but more remain.

I've given up hope on that. Don't think it'll ever compile on 2.95. I'm 
using ndiswrapper and it works nicely.

Jeff.
