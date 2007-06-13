From: Matt Mackall <mpm@selenic.com>
Subject: Re: [RFC][PATCH -mm take5 1/7] marking __init
Date: Wed, 13 Jun 2007 09:34:12 -0500
Message-ID: <20070613143412.GD11115@waste.org>
References: <466FC455.5060001@bx.jp.nec.com> <466FC633.1040404@bx.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Keiichi KII <k-keiichi@bx.jp.nec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:39570 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756060AbXFMOec (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2007 10:34:32 -0400
Content-Disposition: inline
In-Reply-To: <466FC633.1040404@bx.jp.nec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 13, 2007 at 07:25:55PM +0900, Keiichi KII wrote:
> From: Keiichi KII <k-keiichi@bx.jp.nec.com>
> 
> This patch contains the following cleanups.
>  - add __init for initialization functions(option_setup() and
>    init_netconsole()).
> 
> Acked-by: Matt Mackall <mpm@selenic.com>
> Signed-off-by: Keiichi KII <k-keiichi@bx.jp.nec.com>
> Signed-off-by: Takayoshi Kochi <t-kochi@bq.jp.nec.com>

Dave, please take this one. Not sure what to do about the rest, sigh.

-- 
Mathematics is the supreme nostalgia of our time.
