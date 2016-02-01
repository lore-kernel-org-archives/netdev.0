From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] netfilter: ipv4: use preferred kernel types
Date: Mon, 01 Feb 2016 11:41:35 -0800 (PST)
Message-ID: <20160201.114135.1043954624527820660.davem@davemloft.net>
References: <1454159878-20706-1-git-send-email-tanure@linux.com>
	<1454159878-20706-3-git-send-email-tanure@linux.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CCD2580@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tanure@linux.com, pablo@netfilter.org, kaber@trash.net,
	kadlec@blackhole.kfki.hu, kuznet@ms2.inr.ac.ru,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David.Laight@ACULAB.COM
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CCD2580@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Laight <David.Laight@ACULAB.COM>
Date: Mon, 1 Feb 2016 16:37:41 +0000

> From: Lucas Tanure
>> Sent: 30 January 2016 13:18
>> As suggested by checkpatch.pl:
>> CHECK: Prefer kernel type 'uX' over 'uintX_t'
> 
> One might ask why?

We have consistently done this, and consistency is enough of an
argument.
