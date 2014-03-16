From: "Andrew.an" <bh74.an@samsung.com>
Subject: RE: [PATCH V2 RE-SEND 0/7] add new Samsung SXGbE driver
Date: Sat, 15 Mar 2014 17:23:17 -0700
Message-ID: <000f01cf40ad$eecf0be0$cc6d23a0$@samsung.com>
References: <007901cf3e89$37d632e0$a78298a0$%an@samsung.com>
 <20140313.160947.1309757358549172711.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org,
	ilho215.lee@samsung.com
To: 'David Miller' <davem@davemloft.net>
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
In-reply-to: <20140313.160947.1309757358549172711.davem@davemloft.net>
Content-language: en-us
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:
> From: Byungho An <bh74.an@samsung.com>
> Date: Thu, 13 Mar 2014 15:55:28 +0900
> 
> > This is 2nd posting for Samsung SXGbE driver and just re-sending because
> of
> > line wrapping in previous posting.
> >
> > Changes since v1:
> > - changed name of driver to SXGbE as per Ben's comment
> > - squashed Joe's neatening for many stuff in original patches
> 
> I'm mostly happy with this driver, but all of those module parameters
> have to be removed except for 'debug'.
OK, I'll remove them.

> 
> They duplicate functionality provided by ethtool.
OK.

> 
> Module parameters are strongly, if not completely, discouraged.  A
> suitable generic configuration mechanism, such as ethtool, should
> always be used instead.
OK. I'll repost soon. 

Thanks
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
