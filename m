From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Tue, 29 Jul 2014 20:44:34 -0700 (PDT)
Message-ID: <20140729.204434.497235655726897367.davem@davemloft.net>
References: <20140729.165532.599552078692796545.davem@davemloft.net>
	<20140730103628.234a4036@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140730103628.234a4036@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 30 Jul 2014 10:36:28 +1000

> On Tue, 29 Jul 2014 16:55:32 -0700 (PDT) David Miller <davem@davemloft.net> wrote:
>>
>> Oliver Neukum (2):
>>       cdc_subset: deal with a device that needs reset for timeout
> 
> This commit causes a build failure on arm (at least).  See my
> linux-next email about this.

Linus can you just revert that commit after you pull from me for now?

Thanks.
