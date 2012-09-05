From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] cfg80211: use list_move_tail instead of
 list_del/list_add_tail
Date: Wed, 05 Sep 2012 15:40:05 +0200
Message-ID: <1346852405.4364.10.camel@jlt4.sipsolutions.net>
References: <CAPgLHd-7DpM_OQ7RTVip6d-zb8DZS9SiscrMugm2-D992ajjsg@mail.gmail.com>
	 (sfid-20120905_083414_476070_BFBB51A1)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, davem@davemloft.net,
	yongjun_wei@trendmicro.com.cn, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:45062 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752771Ab2IENjg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 09:39:36 -0400
In-Reply-To: <CAPgLHd-7DpM_OQ7RTVip6d-zb8DZS9SiscrMugm2-D992ajjsg@mail.gmail.com> (sfid-20120905_083414_476070_BFBB51A1)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-05 at 14:34 +0800, Wei Yongjun wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Using list_move_tail() instead of list_del() + list_add_tail().
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied, thanks.

johannes
