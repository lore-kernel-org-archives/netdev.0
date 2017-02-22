From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: Re: linux-next: manual merge of the kselftest tree with the net-next
 tree
Date: Wed, 22 Feb 2017 07:54:21 -0700
Message-ID: <a7dfa6bf-1bcb-aa44-4099-a86caf5f1f5a@osg.samsung.com>
References: <20170216142453.53d1f5e5@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        "bamvor.zhangjian@huawei.com" <bamvor.zhangjian@huawei.com>,
        =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>,
        Shuah Khan <shuahkh@osg.samsung.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170216142453.53d1f5e5@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/15/2017 08:24 PM, Stephen Rothwell wrote:
> Hi Shuah,
> 
> Today's linux-next merge of the kselftest tree got a conflict in:
> 
>   tools/testing/selftests/bpf/Makefile
> 
> between commit:
> 
>   d498f8719a09 ("bpf: Rebuild bpf.o for any dependency update")
> 
> from the net-next tree and commit:
> 
>   88baa78d1f31 ("selftests: remove duplicated all and clean target")
> 
> from the kselftest tree.
> 
> I fixed it up (see below) and can carry the fix as necessary. This
> is now fixed as far as linux-next is concerned, but any non trivial
> conflicts should be mentioned to your upstream maintainer when your tree
> is submitted for merging.  You may also want to consider cooperating
> with the maintainer of the conflicting tree to minimise any particularly
> complex conflicts.
> 


Sorry to get back to you late. I was away on vacation last week.
Yes. Please let's plan upon carrying the fix.

thanks,
-- Shuah
