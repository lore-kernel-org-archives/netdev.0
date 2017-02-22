From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: linux-next: manual merge of the kspp tree with the net-next tree
Date: Wed, 22 Feb 2017 07:37:40 +0100
Message-ID: <58AD31B4.3040702@iogearbox.net>
References: <20170222105132.4abc18e8@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Laura Abbott <labbott@redhat.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
        Kees Cook <keescook@google.com>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170222105132.4abc18e8@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/22/2017 12:51 AM, Stephen Rothwell wrote:
> Hi Kees,
>
> Today's linux-next merge of the kspp tree got a conflict in:
>
>    arch/arm/Kconfig
>
> between commit:
>
>    d2852a224050 ("arch: add ARCH_HAS_SET_MEMORY config")
>
> from the net-next tree and commit:
>
>    ad21fc4faa2a ("arch: Move CONFIG_DEBUG_RODATA and CONFIG_SET_MODULE_RONX to be common")
>
> from the kspp tree.
>
> I fixed it up (see below) and can carry the fix as necessary. This
> is now fixed as far as linux-next is concerned, but any non trivial
> conflicts should be mentioned to your upstream maintainer when your tree
> is submitted for merging.  You may also want to consider cooperating
> with the maintainer of the conflicting tree to minimise any particularly
> complex conflicts.

Also looks good to me.
