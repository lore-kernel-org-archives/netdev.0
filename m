From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [BK PATCH] INET6 Updates (2004/10/26)
Date: Mon, 25 Oct 2004 21:51:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041025215114.2d56b7b9.davem@davemloft.net>
References: <20041026.131626.77300437.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20041026.131626.77300437.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 26 Oct 2004 13:16:26 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> Please pull following changesets available at
> <bk://bk.skbuff.net:20610/linux-2.6-inet6-20041026/>.
 ...
> ChangeSet@1.2176, 2004-10-26 12:51:07+09:00, Brian.Haley@hp.com
>  [IPV6] Lookup appropriate destination when sending TCPv6 with routing header.
> ChangeSet@1.2177, 2004-10-26 12:54:41+09:00, yoshfuji@linux-ipv6.org
>  [IPV6] Remove codes related to RTF_ALLONLINK.
> ChangeSet@1.2178, 2004-10-26 12:54:58+09:00, yoshfuji@linux-ipv6.org
>  [IPV6] simplify functions related to RTF_ALLONLINK.
> ChangeSet@1.2179, 2004-10-26 12:55:56+09:00, yoshfuji@linux-ipv6.org
>  [IPV6] NDISC: update neighbor cache entry by RS.
> ChangeSet@1.2180, 2004-10-26 13:11:47+09:00, yoshfuji@linux-ipv6.org
>  [IPV6] kill a warning when building without CONFIG_SYSCTL.

Pulled, thank you Yoshifuji-san.
