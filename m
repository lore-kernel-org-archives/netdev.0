From: Luis Henriques <luis.henriques@canonical.com>
Subject: Re: net: make skb_gso_segment error handling more robust
Date: Tue, 19 May 2015 09:27:02 +0100
Message-ID: <20150519082702.GA1899@ares>
References: <1430779135.4113.202.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, stable <stable@vger.kernel.org>,
	Florian Westphal <fw@strlen.de>,
	Brad Spengler <spender@grsecurity.net>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1430779135.4113.202.camel@decadent.org.uk>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 04, 2015 at 11:38:55PM +0100, Ben Hutchings wrote:
> Brad Spengler pointed out this commit as a candidate for stable:
>=20
> commit 330966e501ffe282d7184fde4518d5e0c24bc7f8
> Author: Florian Westphal <fw@strlen.de>
> Date:   Mon Oct 20 13:49:17 2014 +0200
>=20
>     net: make skb_gso_segment error handling more robust
>=20
> Some hunks need to be dropped for older branches as skb_gso_segment()
> has gained more users over the last few years.
>=20

Thanks Ben, I'll queue this for the 3.16 kernel.

Cheers,
--
Lu=EDs
