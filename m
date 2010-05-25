From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: pull request: wireless-2.6 2010-05-25
Date: Tue, 25 May 2010 16:42:36 -0400
Message-ID: <20100525204235.GA27002@tuxdriver.com>
References: <20100525170401.GE31753@tuxdriver.com>
 <4BFC331A.9030606@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Gertjan van Wingerde <gwingerde@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4BFC331A.9030606@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 25, 2010 at 10:29:14PM +0200, Gertjan van Wingerde wrote:
> On 05/25/10 19:04, John W. Linville wrote:

> > Gertjan van Wingerde (2):
> >       rt2x00: Fix rt2800usb TX descriptor writing.
> 
> The patch causing the breakage this patch fixes wasn't actually upstream yet. So, 
> applying this patch only is now introducing a bug in 2.6.35. I guess it is better
> to revert this patch for 2.6.35.

Hmmm...OK.  Which patch introduces the bug this was intended to fix?

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
