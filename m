From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH]Add new IPv6 MIBs counters support through netlink
Date: Wed, 26 May 2004 16:22:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040526162223.68e9e064.davem@redhat.com>
References: <20040526132215.06e0bc12.davem@redhat.com>
	<OFD49A843C.7EDA1DE2-ON87256EA0.0071A2A0-07256EA0.0071C18B@us.ibm.com>
	<20040526134415.483a6384.davem@redhat.com>
	<20040527.080828.06774575.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: xma@us.ibm.com, mashirle@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040527.080828.06774575.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 27 May 2004 08:08:28 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> Hmm, why are you so hurrying?

I've only added it to my tree and have not pushed it off to Linus.
I was in fact waiting for your feedback to occur first :-)

I see no way we will get the proper u64 support working any
time soon, it is a hard problem to get that right and with
acceptable performance on 32-bit platforms.

About idev in routes, we can add that as an optimization later.

Poor Shirley has waited long enough to get this feature integrated
and given current knowledge it is the best working implementation
we can come up with at this time.
