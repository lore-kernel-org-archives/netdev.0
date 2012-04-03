From: fernando@intellilink.co.jp
Subject: Re: [PATCH 1/2] TCP: update ip_local_port_range documentation
Date: Tue,  3 Apr 2012 20:08:34 +0900
Message-ID: <20120403200834.witdp0frwwo48occ@webmail.int.intellilink.co.jp>
References: <20120403094840.ftxlwztl40gwcg4s@webmail.int.intellilink.co.jp>
	<20120403.005428.1951197638640326467.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=ISO-2022-JP;
	format="flowed"
Content-Transfer-Encoding: 7bit
Cc: "shemminger@vyatta.com" <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ils-mail01.intellilink.co.jp ([61.115.36.70]:39491 "EHLO
	ils-mail01.intellilink.co.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752718Ab2DCLIs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 07:08:48 -0400
In-Reply-To: <20120403.005428.1951197638640326467.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting David Miller <davem@davemloft.net>:

> From: fernando@intellilink.co.jp
> Date: Tue,  3 Apr 2012 09:48:40 +0900
>
>> +	These two numbers determine the number of active connections
>> +	which this system can issue simultaneously to systems not
>> +	supporting TCP extensions (timestamps).
>
> This paragraph is false altogether, it's only true if we have
> one configured IP address.
>
> I'd remove it entirely, it doesn't help anyone and just adds
> confusion.

Done. I will be replying to this email with an updated patch.
