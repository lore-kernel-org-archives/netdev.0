From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPV6: note on shared socket options
Date: Wed, 4 Feb 2004 23:21:09 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040204232109.0ad8d5b9.davem@redhat.com>
References: <20040204.203739.16838230.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040204.203739.16838230.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 04 Feb 2004 20:37:39 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> There're several socket options for multicast
> shared between IPv4 and IPv6.
> Add a note that some range is already used for them.

Applied, thanks Yoshfuji.

As others noted, this in kernel internal headers, our own namespace,
and it's documentation so it's fine.
