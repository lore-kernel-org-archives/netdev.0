From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPV6: Mark MLDv2 Report as known
Date: Fri, 9 Apr 2004 21:13:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040409211353.0f76e33c.davem@redhat.com>
References: <20040409.210510.64268862.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040409.210510.64268862.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 09 Apr 2004 21:05:10 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> Mark MLDv2 Report as known ICMPv6 type.
> (We just ignore MLDv2 Reports on hosts as the spec says.)
> 
> Same patch applies linux-2.4.x.

Applied to both 2.4.x and 2.6.x

Thank you.
