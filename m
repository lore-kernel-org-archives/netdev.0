From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ti: netcp: restore get/set_pad_info()
 functionality
Date: Thu, 18 Feb 2016 15:08:01 -0500 (EST)
Message-ID: <20160218.150801.1433459291829189521.davem@davemloft.net>
References: <1455026303-17014-1-git-send-email-grygorii.strashko@ti.com>
	<20160216.152421.2271194730635382792.davem@davemloft.net>
	<56C5FBA6.3040204@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grygorii.strashko@ti.com, netdev@vger.kernel.org, arnd@arndb.de,
	fcooper@ti.com, nsekhar@ti.com, linux-kernel@vger.kernel.org,
	w-kwok2@ti.com, mugunthanvnm@ti.com
To: m-karicheri2@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56C5FBA6.3040204@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Murali Karicheri <m-karicheri2@ti.com>
Date: Thu, 18 Feb 2016 12:13:10 -0500

> On 02/16/2016 03:24 PM, David Miller wrote:
>> 
>> I would like some of the feedback to be taken into consideration and
>> integrated into this patch.
>> 
>> Part of the reason this regression was introduced was probably because
>> the purpose of some fields or descriptor semantics was not defined
>> properly.
>> 
>> Therefore it is absolutely appropriate to properly name and document
>> these fields as part of the bug fix.
>> 
>> Thank you.
>> 
> David,
> 
> I will take over this from Grygorii as he is out of office. 
> 
> I propose to keep this patch as is and add additional patch to address
> the feedback in the same series (v1). Is that fine with you?

No, I want the code to be clarified along with the bug fix so that
this bug is unlikely to resurface.
