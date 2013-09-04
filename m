From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: correctly interlink lower/upper devices
Date: Wed, 04 Sep 2013 00:53:40 -0400 (EDT)
Message-ID: <20130904.005340.2168000201572856365.davem@davemloft.net>
References: <1378132011-2910-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, jiri@resnulli.us,
	alexander.h.duyck@intel.com, amwang@redhat.com
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54654 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756320Ab3IDExl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 00:53:41 -0400
In-Reply-To: <1378132011-2910-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Mon,  2 Sep 2013 16:26:51 +0200

> Currently we're linking upper devices to lower ones, which results in
> upside-down relationship: upper devices seeing lower devices via its upper
> lists.
> 
> Fix this by correctly linking lower devices to the upper ones.
> 
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

Applied.
