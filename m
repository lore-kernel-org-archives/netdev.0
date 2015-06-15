From: Zefan Li <lizefan@huawei.com>
Subject: Re: net: make skb_gso_segment error handling more robust
Date: Mon, 15 Jun 2015 11:39:18 +0800
Message-ID: <557E48E6.2000604@huawei.com>
References: <1430779135.4113.202.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, stable <stable@vger.kernel.org>,
	Florian Westphal <fw@strlen.de>,
	"Brad Spengler" <spender@grsecurity.net>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1430779135.4113.202.camel@decadent.org.uk>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 2015/5/5 6:38, Ben Hutchings wrote:
> Brad Spengler pointed out this commit as a candidate for stable:
> 
> commit 330966e501ffe282d7184fde4518d5e0c24bc7f8
> Author: Florian Westphal <fw@strlen.de>
> Date:   Mon Oct 20 13:49:17 2014 +0200
> 
>     net: make skb_gso_segment error handling more robust
> 
> Some hunks need to be dropped for older branches as skb_gso_segment()
> has gained more users over the last few years.
> 

Queued up for 3.4. Thanks!
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (MingW32)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlV+SNYACgkQWyV2+h1UztPyxQCgsQqvmlh5Vo9HFiExdFGd4QVx
nyoAoMXKJsGfeLfhJ921fdYsKBYUjNz2
=Wpjj
-----END PGP SIGNATURE-----
