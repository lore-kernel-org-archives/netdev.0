From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6] [IPV6] SIT: dst leakage in error path.
Date: Sun, 3 Oct 2004 14:57:27 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041003145727.5a58d236.davem@davemloft.net>
References: <20041002.193138.94763422.yoshfuji@linux-ipv6.org>
	<20041002.193424.76694251.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20041002.193424.76694251.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 02 Oct 2004 19:34:24 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> In article <20041002.193138.94763422.yoshfuji@linux-ipv6.org> (at Sat, 02 Oct 2004 19:31:38 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:
> 
> > We failed to put rt in error path.
> > 
> > Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> 
> And this also applies 2.4 (with some fuzz).

Applied to both trees, thanks.
