From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add new QCA alx ethernet driver
Date: Wed, 08 Aug 2012 23:14:14 -0700 (PDT)
Message-ID: <20120808.231414.2103406027652335204.davem@davemloft.net>
References: <1344507270-2907-1-git-send-email-cjren@qca.qualcomm.com>
	<6349D7A510622448B1BA0967850A8438013692CA@NASANEXD02D.na.qualcomm.com>
	<1344485382.2024.9.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: cjren@qca.qualcomm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, qca-linux-team@qualcomm.com,
	nic-devel@qualcomm.com, xiong@qca.qualcomm.com,
	hao-ran.liu@canonical.com, rodrigue@qca.qualcomm.com
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344485382.2024.9.camel@joe2Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 08 Aug 2012 21:09:42 -0700

> On Thu, 2012-08-09 at 02:27 +0000, Ren, Cloud wrote:
>> Hi David,
> []
>> The alx driver only supports two new nics(l1f/l2f) now.  It doesn't supersede atl1c driver.
>> Atl1c driver still supports old nics.
> []
>> -----Original Message-----
>> From: Ren, Cloud 
>> Sent: 2012年8月9日 18:15
> []
>> This driver support two new ethernet chipsets:
> 
> [+400kb of entire original patch]
> 
> Did you really have to quote 400kb of original patch to
> make that prefixing statement to David?
> 
> []
> 
>> Signed-off-by: Joe Perches <joe@perches.com>
>  
> I would prefer my name not be listed as a Signed-off-by.

You should never EVER add a signoff, or any other kind of tag, of
another person unless they give it to you explicitly.  It is beyond
rude to do this without that person's permission.

You qualcomm guys are really mishandling this patch submission,
and just like last time you are steadily pissing me off.

You have a very low level of consideration for other people who feel
the burdon of your work, and you often have no idea what the hell you
are doing.
