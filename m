From: "David S. Miller" <davem@davemloft.net>
Subject: Re: IPv6 dead in -bk11
Date: Wed, 3 Nov 2004 12:08:48 -0800
Message-ID: <20041103120848.632e8fee.davem@davemloft.net>
References: <20041102.225343.06193184.yoshfuji@linux-ipv6.org>
	<4187A4E3.8010600@pobox.com>
	<20041103.012923.102810732.yoshfuji@linux-ipv6.org>
	<20041104.012128.51410945.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: jgarzik@pobox.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        akpm@osdl.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20041104.012128.51410945.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 04 Nov 2004 01:21:28 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> In article <20041103.012923.102810732.yoshfuji@linux-ipv6.org> (at Wed, 03 Nov 2004 01:29:23 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:
> 
> > So... I guess that kernel failed to add "default route" on receipt of RA.
> > Right?
> :
> 
> Sorry, this bug was introduced by my changeset:
> <http://linux.bkbits.net:8080/linux-2.5/cset@417dca81tJ4RRAxhWTbn0p6hI-1XIQ>.
> 
> David, this should fix the issue.

Patch applied, thanks for tracking down and fixing this bug.
