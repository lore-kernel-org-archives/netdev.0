From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: linux-next: manual merge of the net-next tree with Linus' tree
Date: Tue, 14 Jul 2015 10:23:22 +0200
Message-ID: <55A4C6FA.7090200@cumulusnetworks.com>
References: <20150714114617.1eae8765@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20150714114617.1eae8765@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/14/2015 03:46 AM, Stephen Rothwell wrote:
> Hi all,
> 
> Today's linux-next merge of the net-next tree got a conflict in:
> 
>   net/bridge/br_mdb.c
> 
> between commit:
> 
>   f1158b74e54f ("bridge: mdb: zero out the local br_ip variable before use")
> 
> from Linus' tree and commit:
> 
>   74fe61f17e99 ("bridge: mdb: add vlan support for user entries")
> 
> from the net-next tree.
> 
> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).
> 

Looks good to me, thanks Stephen!

Cheers,
 Nik
