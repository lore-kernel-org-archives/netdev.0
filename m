From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: Re: linux-next: manual merge of the kselftest tree with the net-next
 tree
Date: Tue, 24 Jan 2017 08:17:21 -0700
Message-ID: <fd85f7f5-ab0d-3bf5-784d-872f926dd7d7@osg.samsung.com>
References: <20170124154524.2a993739@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        David Herrmann <dh.herrmann@gmail.com>,
        Daniel Mack <daniel@zonque.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Bamvor Jian Zhang <bamvor.zhangjian@linaro.org>,
        "bamvor.zhangjian@huawei.com" <bamvor.zhangjian@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170124154524.2a993739@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/23/2017 09:45 PM, Stephen Rothwell wrote:
> Hi Shuah,
> 
> Today's linux-next merge of the kselftest tree got a conflict in:
> 
>   tools/testing/selftests/bpf/Makefile
> 
> between commit:
> 
>   4d3381f5a322 ("bpf: Add tests for the lpm trie map")
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

Yes. Please.

> 
> P.S. Shuah, that kselftest commit has a different email address in its
> Author and Signed-off-by.
> 


Yes you are right. I didn't notice the discrepancy.

Bamvor! Your gitconfig is outdated perhaps!

thanks,
-- Shuah
