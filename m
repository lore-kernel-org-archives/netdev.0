From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Fri, 04 Mar 2016 03:17:40 +0100
Message-ID: <56D8F044.4080004@iogearbox.net>
References: <20160304130949.47a94ac8@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jiri Benc <jbenc@redhat.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160304130949.47a94ac8@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/04/2016 03:09 AM, Stephen Rothwell wrote:
> Hi all,
>
> Today's linux-next merge of the net-next tree got a conflict in:
>
>    drivers/net/vxlan.c
>
> between commit:
>
>    4024fcf70556 ("vxlan: fix missing options_len update on RX with collect metadata")
>
> from the net tree and commit:
>
>    3288af0892e3 ("vxlan: move GBP header parsing to a separate function")
>
> from the net-next tree.
>
> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).

Looks good, thanks!
