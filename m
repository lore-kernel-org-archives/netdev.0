From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: linux-next: manual merge of the net-next tree with Linus' tree
Date: Thu, 05 Sep 2013 09:33:10 +0200
Message-ID: <522833B6.2040804@redhat.com>
References: <20130905151933.10e0558611271fdd2133a790@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130905151933.10e0558611271fdd2133a790@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/05/2013 07:19 AM, Stephen Rothwell wrote:
> Hi all,
>
> Today's linux-next merge of the net-next tree got a conflict in
> net/bridge/br_multicast.c between commit 2d98c29b6fb3 ("net: bridge:
> convert MLDv2 Query MRC into msecs_to_jiffies for max_delay") from Linus'
> tree and commit e3f5b17047de ("net: ipv6: mld: get rid of MLDV2_MRC and
> simplify calculation") from the net-next tree.
>
> I just used the net-next tree version and can carry the fix as necessary
> (no action is required).

Sounds good thanks Stephen!
