From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [PATCH 06/14] ipw2100: Make ipw2100 depends on known working
	platforms
Date: Tue, 22 Aug 2006 12:50:30 +0800
Message-ID: <1156222231.17642.350.camel@debian.sh.intel.com>
References: <20060821033748.GA5371@mail.intel.com>
	 <20060821095215.GB2770@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:28004 "EHLO
	orsmga101-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S1751301AbWHVEwc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 00:52:32 -0400
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20060821095215.GB2770@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-08-21 at 10:52 +0100, Christoph Hellwig wrote:
> There's a lot more little endian platforms than just the intel ones,
> aswell.
> 
> It seems you're totally unsuitable as a driver or subsystem maintainer
> if you favour you own employer so much.

I'm not saying I'm not going to support it in the future. But currently
ipw2100 doesn't support big endian machines is the truth. One reason is
because I don't have such a box with an ipw2100 card. If you or someone
has such a platform and is willing to try patches for me, I'm happy to
get this done. That's why the ipw2200 driver has the BE supported.

Thanks,
-yi
