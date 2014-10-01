From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: linux-next: manual merge of the net-next tree with the berlin
 tree
Date: Wed, 01 Oct 2014 20:31:54 +0200
Message-ID: <542C489A.6020207@gmail.com>
References: <20141001112212.44f53d35@canb.auug.org.au>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	=?windows-1252?Q?Antoine_T=E9nart?=
	<antoine.tenart@free-electrons.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20141001112212.44f53d35@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01.10.2014 03:22, Stephen Rothwell wrote:
> Today's linux-next merge of the net-next tree got a conflict in
> arch/arm/boot/dts/berlin2q-marvell-dmp.dts between commit 461316fca705
> ("ARM: berlin: enable the eSATA interface on the BG2Q DMP") from the
> berlin tree and commit 75215193b975 ("ARM: dts: berlin: enable the
> Ethernet port on the BG2Q DMP") from the net-next tree.
>
> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).

Looks good to me,

Thanks Stephen!

Sebastian
