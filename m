From: David Miller <davem@davemloft.net>
Subject: Re: [patch] rtnetlink: remove an unneeded test
Date: Thu, 15 Aug 2013 01:29:17 -0700 (PDT)
Message-ID: <20130815.012917.1487592493292532518.davem@davemloft.net>
References: <20130814093542.GC521@elgon.mountain>
	<8761v8aww3.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, john.r.fastabend@intel.com,
	jiri@resnulli.us, vyasevic@redhat.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <8761v8aww3.fsf@xmission.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 14 Aug 2013 12:35:24 -0700

> Dan Carpenter <dan.carpenter@oracle.com> writes:
> 
>> We know that "dev" is a valid pointer at this point, so we can remove
>> the test and clean up a little.
> 
> Quite right.
> 
> Reviewed-by: "Eric W. Biederman" <ebiederm@xmission.com>
> 
>>
>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied to net-next, thanks.
