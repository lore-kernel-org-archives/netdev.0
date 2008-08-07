From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: meant hlist_* - Re: hash_list and rcu locking question
Date: Thu, 7 Aug 2008 07:53:44 +0400
Message-ID: <20080807035344.GA18861@2ka.mipt.ru>
References: <379e30200808061849w3a47f981s5ccde245059f595b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NetDev <netdev@vger.kernel.org>
To: Tobias Koeck <tobias.koeck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:43780 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753324AbYHGDxb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Aug 2008 23:53:31 -0400
Content-Disposition: inline
In-Reply-To: <379e30200808061849w3a47f981s5ccde245059f595b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 07, 2008 at 03:49:43AM +0200, Tobias Koeck (tobias.koeck@gmail.com) wrote:
> I mean the rcu function for the hlist_{head,list} ....

include/linux/rculist.h : hlist_for_each_entry_rcu and friends.
Does it contain needded calls?

-- 
	Evgeniy Polyakov
