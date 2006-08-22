From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 06/14] ipw2100: Make ipw2100 depends on known working platforms
Date: Tue, 22 Aug 2006 10:11:22 +0100
Message-ID: <20060822091122.GA14142@infradead.org>
References: <20060821033748.GA5371@mail.intel.com> <20060821095215.GB2770@infradead.org> <1156222231.17642.350.camel@debian.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:7072 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1750785AbWHVJL1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 05:11:27 -0400
To: Zhu Yi <yi.zhu@intel.com>
Content-Disposition: inline
In-Reply-To: <1156222231.17642.350.camel@debian.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 22, 2006 at 12:50:30PM +0800, Zhu Yi wrote:
> I'm not saying I'm not going to support it in the future. But currently
> ipw2100 doesn't support big endian machines is the truth. One reason is
> because I don't have such a box with an ipw2100 card. If you or someone
> has such a platform and is willing to try patches for me, I'm happy to
> get this done. That's why the ipw2200 driver has the BE supported.

I'm happy to test ipw2100 on big endian systems if you send me a card.

