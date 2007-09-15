From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] [IPV6]: Fix unbalanced socket reference with
 MSG_CONFIRM.
Date: Fri, 14 Sep 2007 17:17:37 -0700 (PDT)
Message-ID: <20070914.171737.59665830.davem@davemloft.net>
References: <20070913.093039.76110425.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:60786
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755277AbXIOARm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2007 20:17:42 -0400
In-Reply-To: <20070913.093039.76110425.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Thu, 13 Sep 2007 09:30:39 +0900 (JST)

> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied, I'll push to -stable after it lands in Linus's tree.

Thank you.
