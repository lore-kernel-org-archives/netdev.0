From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phylib: export phy_suspend and phy_resume
Date: Tue, 08 Apr 2014 13:04:14 -0400 (EDT)
Message-ID: <20140408.130414.751183135423854989.davem@davemloft.net>
References: <20140408071101.GA14453@gmail.com>
	<CAGVrzcY5aa5z36qooLqRZv2b_z=mJd2KeOjs9W5uWDSZ1hjRdQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tobias@waldekranz.com, sebastian.hesselbarth@gmail.com,
	netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43840 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932078AbaDHREP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 13:04:15 -0400
In-Reply-To: <CAGVrzcY5aa5z36qooLqRZv2b_z=mJd2KeOjs9W5uWDSZ1hjRdQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 8 Apr 2014 08:26:39 -0700

> 2014-04-08 0:11 GMT-07:00 Tobias Waldekranz <tobias@waldekranz.com>:
>> These functions are exported in include/linux/phy.h but the symbol
>> exports where missing.
> 
> Thanks! I had this sitting somewhere and somehow forgot to send it.
> 
>>
>> Signed-off-by: Tobias Waldekranz <tobias@waldekranz.com>
> 
> Acked-by: Florian Fainelli <f.fainelli@gmail.com>

I don't want to see these exported until there is an actual use.
