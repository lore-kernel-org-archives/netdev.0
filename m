From: Ben Greear <greearb@candelatech.com>
Subject: Re: Allowing netlink_family to be any integer
Date: Thu, 21 Oct 2004 16:02:27 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41784003.7070505@candelatech.com>
References: <20041021142527.GG3551@sunbeam.de.gnumonks.org> <E1CKkWZ-0005x5-00@gondolin.me.apana.org.au> <20041021225315.GH19714@rei.reeler.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Harald Welte <laforge@netfilter.org>, lmb@suse.de, ahu@ds9a.nl,
        hch@infradead.org, netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041021225315.GH19714@rei.reeler.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:

> The only real problem I see is sk_protocol being only 8bit as
> limiting factor.

When you fix this, please make the route-table ID at least 16 bits as well :)

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
