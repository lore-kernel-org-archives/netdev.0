From: Shrikrishna Khare <skhare@vmware.com>
Subject: Re: [PATCH] Driver: Vmxnet3: Fix regression caused by cec0556
Date: Mon, 14 Mar 2016 16:21:53 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1603141620520.7592@shri-linux.eng.vmware.com>
References: <1457731784-96240-1-git-send-email-skhare@vmware.com> <20160314.152845.1840060808684295471.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, gyang@vmware.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160314.152845.1840060808684295471.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Mon, 14 Mar 2016, David Miller wrote:

> From: Shrikrishna Khare <skhare@vmware.com>
> Date: Fri, 11 Mar 2016 13:29:44 -0800
> 
> > don't pass uninitialized flags to spin_unlock_irqrestore.
> > 
> > Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Signed-off-by: Shrikrishna Khare <skhare@vmware.com>
> > Signed-off-by: Guolin Yang <gyang@vmware.com>
> 
> Sorry, I noticed Arnd's version of this fix first and therefore applied
> his version.

No problem. Arnd's version is same as the fix I sent. 

Thanks,
Shri
