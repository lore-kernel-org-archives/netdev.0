From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: linux-next: manual merge of the kselftest tree with the net-next
 tree
Date: Wed, 25 Jan 2017 08:39:11 +0100
Message-ID: <5888561F.9080503@iogearbox.net>
References: <20170125150321.0b377f57@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        "bamvor.zhangjian@huawei.com" <bamvor.zhangjian@huawei.com>,
        Bamvor Jian Zhang <bamvor.zhangjian@linaro.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
        Shuah Khan <shuahkh@osg.samsung.com>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170125150321.0b377f57@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/25/2017 05:03 AM, Stephen Rothwell wrote:
> Hi Shuah,
>
> Today's linux-next merge of the kselftest tree got a conflict in:
>
>    tools/testing/selftests/bpf/Makefile
>
> between commit:
>
>    62b64660262a ("bpf: add prog tag test case to bpf selftests")
>
> from the net-next tree and commit:
>
>    88baa78d1f31 ("selftests: remove duplicated all and clean target")
>
> from the kselftest tree.
>
> I fixed it up (see below) and can carry the fix as necessary. This
> is now fixed as far as linux-next is concerned, but any non trivial
> conflicts should be mentioned to your upstream maintainer when your tree
> is submitted for merging.  You may also want to consider cooperating
> with the maintainer of the conflicting tree to minimise any particularly
> complex conflicts.

Looks good to me, thanks!
