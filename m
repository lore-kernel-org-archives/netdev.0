From: David Miller <davem@davemloft.net>
Subject: Re: remove unnecessary config.h includes from net/
Date: Wed, 09 Aug 2006 21:04:38 -0700 (PDT)
Message-ID: <20060809.210438.110013064.davem@davemloft.net>
References: <20060810022116.GB23634@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:18331
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932287AbWHJEEb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Aug 2006 00:04:31 -0400
To: davej@redhat.com
In-Reply-To: <20060810022116.GB23634@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dave Jones <davej@redhat.com>
Date: Wed, 9 Aug 2006 22:21:16 -0400

> config.h is automatically included by kbuild these days.
> 
> Signed-off-by: Dave Jones <davej@redhat.com>

Applied to net-2.6.19, thanks Dave.
