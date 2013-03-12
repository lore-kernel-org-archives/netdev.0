From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] tcp: Tail loss probe (TLP)
Date: Tue, 12 Mar 2013 08:45:11 -0400 (EDT)
Message-ID: <20130312.084511.2084380274656660047.davem@davemloft.net>
References: <1363032044-27315-1-git-send-email-nanditad@google.com>
	<CADVnQy=V0+vdc=rT8Kc1jVc4DUAqamNt3emig+bpqgEg47k2Nw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nanditad@google.com, ycheng@google.com, edumazet@google.com,
	netdev@vger.kernel.org, ilpo.jarvinen@cs.helsinki.fi,
	therbert@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51127 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754975Ab3CLMpE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 08:45:04 -0400
In-Reply-To: <CADVnQy=V0+vdc=rT8Kc1jVc4DUAqamNt3emig+bpqgEg47k2Nw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Mon, 11 Mar 2013 17:37:28 -0400

> On Mon, Mar 11, 2013 at 4:00 PM, Nandita Dukkipati <nanditad@google.com> wrote:
>> This patch series implement the Tail loss probe (TLP) algorithm described
>> in http://tools.ietf.org/html/draft-dukkipati-tcpm-tcp-loss-probe-01. The
>> first patch implements the basic algorithm.
 ...
>> Signed-off-by: Nandita Dukkipati <nanditad@google.com>
>> ---
> 
> Acked-by: Neal Cardwell <ncardwell@google.com>

Looks good, applied, thanks.
