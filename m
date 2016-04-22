From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/4] libnl: enhance API to ease 64bit
 alignment for attribute
Date: Fri, 22 Apr 2016 01:31:39 -0400 (EDT)
Message-ID: <20160422.013139.473031789952789916.davem@davemloft.net>
References: <1461257907-4458-1-git-send-email-nicolas.dichtel@6wind.com>
	<20160421.142831.1815562418742721577.davem@davemloft.net>
	<57194D69.4040206@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	eric.dumazet@gmail.com, tgraf@suug.ch, jhs@mojatatu.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58184 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753506AbcDVFbq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 01:31:46 -0400
In-Reply-To: <57194D69.4040206@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri, 22 Apr 2016 00:00:09 +0200

> Le 21/04/2016 20:28, David Miller a =E9crit :
>>
>> Applied to net-next.
>>
>> I did a quick scan and the following jumped out at me as cases we ne=
ed
>> to fix up as well:
> Did you grep something or just catch this by code review?

It was a "grep and check" kind of thing, yes.
