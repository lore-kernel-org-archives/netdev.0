From: Antonio Quartulli <ordex@autistici.org>
Subject: Re: [patch net-next 5/7] net: remove unnecessary
 =?UTF-8?Q?NET=5FADDR=5FRANDOM=20=22bitclean=22?=
Date: Thu, 10 Jan 2013 04:55:23 +0200
Message-ID: <315462fcac2927e7ddac59ce6bb97148@autistici.org>
References: <1357047019-1037-1-git-send-email-jiri@resnulli.us>
 <1357047019-1037-6-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from diserzione.investici.org ([82.221.99.153]:34321 "EHLO
	diserzione.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757961Ab3AJCz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2013 21:55:28 -0500
In-Reply-To: <1357047019-1037-6-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Il 01.01.2013 15:30 Jiri Pirko ha scritto:
> NET_ADDR_SET is set in dev_set_mac_address() no need to alter
> dev->addr_assign_type value in drivers.
>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Hello Jiri,

please, next time it would be good if you CC all the poeple involved in 
a patch: in this way
everybody can easily realise that the code they are maintaining is 
going to be touched/modified.
If you don't (like this time) we have to wait some somebody/something 
comparing net-next with
our tree to trigger a reaction in our repo.

The get_maintainer.pl script will give you all the email addresses that 
you should include
(some of them can possibly be skept).

Thanks a lot,
Antonio


-- 
Antonio Quartulli
