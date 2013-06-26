From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the final tree
 (net-next tree related)
Date: Wed, 26 Jun 2013 01:36:20 -0700 (PDT)
Message-ID: <20130626.013620.38647708061243546.davem@davemloft.net>
References: <20130626175610.8a8b6606fd9a5b6269398059@canb.auug.org.au>
	<4881796E12491D4BB15146FE0209CE643F603C48@DE02WEMBXB.internal.synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexey.Brodkin@synopsys.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4881796E12491D4BB15146FE0209CE643F603C48@DE02WEMBXB.internal.synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Date: Wed, 26 Jun 2013 08:07:37 +0000

> On 06/26/2013 11:56 AM, Stephen Rothwell wrote:
>> Hi all,
>>
>> After merging the final tree, today's linux-next build (powerpc
>> allyesconfig) failed like this:
> []
>> Caused by commit e4f2379db6c6 ("ethernet/arc/arc_emac - Add new driver")
>> from the net-next tree.
>>
>> I have reverted that commit for today.
> 
> I've just sent a patch that fixes reported issues (both errors and 
> warnings).

And I've just applied it.
