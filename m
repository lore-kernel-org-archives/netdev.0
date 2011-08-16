From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the final tree (net
 tree related)
Date: Tue, 16 Aug 2011 00:17:11 -0700 (PDT)
Message-ID: <20110816.001711.169179303753669881.davem@davemloft.net>
References: <20110816152815.911f15937efa2ebf58a2795d@canb.auug.org.au>
	<20110815.231116.1728582609642497613.davem@davemloft.net>
	<20110816165744.5c069b0c9f2e329e48ecd7d0@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110816165744.5c069b0c9f2e329e48ecd7d0@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 16 Aug 2011 16:57:44 +1000

> Hi Dave,
> 
> On Mon, 15 Aug 2011 23:11:16 -0700 (PDT) David Miller <davem@davemloft.net> wrote:
>>
>> Please test this patch:
>> 
>> --------------------
>> net: Fix sungem_phy sharing.
> 
> This fixes my allyesconfig build (and doesn't break any of the others :-)).
> 
> Tested-by: Stephen Rothwell <sfr@canb.auug.org.au>

Thanks a lot for testing.
