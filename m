From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH linus] tcp: md5: tcp_md5_do_lookup_exact() can be
 static
Date: Thu, 06 Jul 2017 10:55:38 +0100 (WEST)
Message-ID: <20170706.105538.1784895348831188824.davem@davemloft.net>
References: <201707060719.Zvm7chOj%fengguang.wu@intel.com>
        <20170705235853.GA69361@lkp-sb04.lkp.intel.com>
        <20170706102712.3904c199@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, kbuild-all@01.org,
        linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        netdev@vger.kernel.org, colona@arista.com, gilligan@arista.com,
        mowat@arista.com
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170706102712.3904c199@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 6 Jul 2017 10:27:12 +1000

> Hi,
> 
> Not sure why you sent this to me ... it fixes a commit in the net-next
> tree (now in Linus' tree) ...
> 
> On Thu, 6 Jul 2017 07:58:53 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:
>>
>> Fixes: 0c5f0311f690 ("Add linux-next specific files for 20170705")
> 
> Actually:  Fixes: 6797318e623d ("tcp: md5: add an address prefix for key lookup")

Applied with correct fixes tag, thanks.
