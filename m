From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Trivial ipv6 fix.
Date: Mon, 2 Aug 2004 17:08:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040802170817.3f9be894.davem@redhat.com>
References: <1091434328.16469.5.camel@localhost.localdomain>
	<20040802.065940.86004622.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: suckfish@ihug.co.nz, pekkas@netcore.fi, linux-kernel@vger.kernel.org,
        yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040802.065940.86004622.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 02 Aug 2004 06:59:40 -0700 (PDT)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> In article <1091434328.16469.5.camel@localhost.localdomain> (at Mon, 02 Aug 2004 20:12:08 +1200), Ralph Loader <suckfish@ihug.co.nz> says:
> 
> > ipv6_addr_hash doesn't do what it's comment says.  The comment was
> > probably what was intended, not that it'll make much difference in
> > practice.
> 
> Oops, David, please apply this.

Done, thanks guys.
