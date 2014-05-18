From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCHv4 0/5] Add DT support for fixed PHYs
Date: Sun, 18 May 2014 10:21:10 -0700
Message-ID: <CAGVrzcYN1-0zM0pVSFZkD5HVAwq6rXEQOBN29x+vBn9hpbmOcA@mail.gmail.com>
References: <1400249647-4643-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <20140516.172009.632611701865367987.davem@davemloft.net> <20140518121854.3b4a17fa@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <robh+dt@kernel.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Christian Gmeiner <christian.gmeiner@gmail.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:57138 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752378AbaERRVv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 May 2014 13:21:51 -0400
In-Reply-To: <20140518121854.3b4a17fa@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-05-18 3:18 GMT-07:00 Thomas Petazzoni
<thomas.petazzoni@free-electrons.com>:
> Dear David Miller,
>
> On Fri, 16 May 2014 17:20:09 -0400 (EDT), David Miller wrote:
>> From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
>> Date: Fri, 16 May 2014 16:14:02 +0200
>>
>> > Here is a fourth version of the patch set that adds a Device Tree
>> > binding and the related code to support fixed PHYs. I'm hoping to get
>> > this merged in 3.16.
>>
>> Series applied, thanks Thomas.
>
> Thanks! Did you also pull PATCH 5/5, which changes the Armada XP Matrix
> Device Tree file?

It has been applied:
http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=84f6e11f21d40025ae9b0ebbf1c9b3be91ea8e1a
-- 
Florian
