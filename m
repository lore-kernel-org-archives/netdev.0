From: David Miller <davem@davemloft.net>
Subject: Re: Please backport dev_kfree_skb_any fixes for stable
Date: Tue, 21 Apr 2015 14:14:06 -0400 (EDT)
Message-ID: <20150421.141406.1399467592189654007.davem@davemloft.net>
References: <CAHTgTXWvDs4fTg_Gpsn8XrYnHbgZOKC4ymkq_QVdnGVCOaiqzw@mail.gmail.com>
	<20150325.140358.1369150767101881939.davem@davemloft.net>
	<CAHTgTXVokVeq9Og6pEpRyhqtKuzFD4VHkMn_pnBUtt-V8ecxVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org,
	cwang@twopensource.com
To: vlee@twopensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54588 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754530AbbDUSOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2015 14:14:08 -0400
In-Reply-To: <CAHTgTXVokVeq9Og6pEpRyhqtKuzFD4VHkMn_pnBUtt-V8ecxVA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vinson Lee <vlee@twopensource.com>
Date: Wed, 25 Mar 2015 12:39:01 -0700

> Please backport the list of commits from the original stable request
> at http://permalink.gmane.org/gmane.linux.network/320390.
> 
> The patches are from 3.15. Please queue them up for kernels <= 3.14.

Ok, doing that right now, thanks.
