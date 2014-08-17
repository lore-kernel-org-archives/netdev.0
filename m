From: Andreea Bernat <bernat.ada@gmail.com>
Subject: Re: [PATCH] rcu: Replace rcu_dereference() with rcu_access_pointer()
Date: Sun, 17 Aug 2014 13:04:21 +0300
Message-ID: <CALDM6bov98jkjiUgPevE=Ha0Uh_QDR7Ee-enB5DtQ1WKVLUnig@mail.gmail.com>
References: <20140816193442.GA6471@ada>
	<20140816.185002.1499212551659532229.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jay Vosburgh <j.vosburgh@gmail.com>, vfalico@gmail.com,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Paul McKenney <paulmck@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f181.google.com ([74.125.82.181]:52197 "EHLO
	mail-we0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751392AbaHQKEX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2014 06:04:23 -0400
In-Reply-To: <20140816.185002.1499212551659532229.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry, I will send a version two of the patches with the subject line
changed.

Thank you,
Andreea

2014-08-17 4:50 GMT+03:00 David Miller <davem@davemloft.net>:
>
> Please do not use the same exact Subject line for all of these patches.
>
> Otherwise nobody reading the shortlog can tell what might be different
> from one patch to another.
>
> Instead, use a subsystem prefix for the place where you're making
> your change.  For example, for the two networking patches you could
> replace "rcu: " with "bonding: " and "cnic: ".
>
> Thanks.
