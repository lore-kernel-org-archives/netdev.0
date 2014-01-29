From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tun: add device name(iff) field to proc fdinfo entry
Date: Tue, 28 Jan 2014 18:08:19 -0800 (PST)
Message-ID: <20140128.180819.623844973390653379.davem@davemloft.net>
References: <1390928051-6113-1-git-send-email-yamato@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yamato@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48116 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751553AbaA2CIU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jan 2014 21:08:20 -0500
In-Reply-To: <1390928051-6113-1-git-send-email-yamato@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Masatake YAMATO <yamato@redhat.com>
Date: Wed, 29 Jan 2014 01:54:11 +0900

>     # cat /proc/4565/fdinfo/25
>     pos:	138
>     flags:	0104002
>     iff: vnet0

Please properly indent iff just like the other fdinfo fields
are.

Thanks.
