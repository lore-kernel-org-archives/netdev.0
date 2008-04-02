From: David Miller <davem@davemloft.net>
Subject: Re: GFP_ATOMIC page allocation failures.
Date: Wed, 02 Apr 2008 13:53:46 -0700 (PDT)
Message-ID: <20080402.135346.212926761.davem@davemloft.net>
References: <20080402195428.95A3.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080402.114441.78726196.davem@davemloft.net>
	<1207167128.5311.5.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, kosaki.motohiro@jp.fujitsu.com,
	akpm@linux-foundation.org, csnook@redhat.com,
	davej@codemonkey.org.uk, nickpiggin@yahoo.com.au,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33611
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755207AbYDBUxq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 16:53:46 -0400
In-Reply-To: <1207167128.5311.5.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 02 Apr 2008 12:12:06 -0800

> tg3 hardware has a jumbo rx ring that can accommodate non-linear SKBs.
> Matt is working on some patches to add this feature.

Excellent.
