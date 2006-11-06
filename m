From: Jean-Mickael Guerin <jean-mickael.guerin@6wind.com>
Subject: Re: (usagi-core 31424) Re: [PATCH 7/13] [RFC] [IPV6] Move source
 address selection into route lookup.
Date: Mon, 06 Nov 2006 10:37:44 +0100
Message-ID: <454F0268.7030106@6wind.com>
References: <20061018.230850.91573842.yoshfuji@linux-ipv6.org>	<4536E279.1090003@jp.ibm.com>	<4549E8B3.4070601@tcs.hut.fi> <20061102.221339.102356265.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vnuorval@tcs.hut.fi, mitch@jp.ibm.com, usagi-core@linux-ipv6.org,
	davem@davemloft.net, tgraf@suug.ch, kim.nordlund@nokia.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:22541 "EHLO
	proxy.6wind.com") by vger.kernel.org with ESMTP id S1423642AbWKFJh4
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Nov 2006 04:37:56 -0500
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
In-Reply-To: <20061102.221339.102356265.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ reposted, with better subject ]
>>> http://testlab.linux-ipv6.org/tahi-autorun.2/net-2.6_20061018/
>> The host testlab.linux-ipv6.org doesn't seem to be visible to the
>> outside world so could you post the results somewhere where I could take
>> a closer look at the results?
>
> It is visible world-wide, assuming you have IPv6 connection.
With IPv4-only connection, one can try to append ".ipv4.sixxs.org":

http://testlab.linux-ipv6.org.ipv4.sixxs.org/tahi-autorun.2/net-2.6_20061018/ 


Jean-Mickael
