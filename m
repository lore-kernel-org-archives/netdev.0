From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPV6: add missing sentinel for addrconf procfs
Date: Mon, 19 Jan 2004 20:55:57 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040119205557.3de4b261.davem@redhat.com>
References: <20040120.094223.76534381.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / _$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
In-Reply-To: <20040120.094223.76534381.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 20 Jan 2004 09:42:23 +0900 (JST)
YOSHIFUJI Hideaki / _$B5HF#1QL@ <yoshfuji@linux-ipv6.org> wrote:

> Sorry, I forgot to increase the number of members in the array and 
> that the sentinel was removed.
> So, add missing sentinel explicitly.

Applied, thanks yoshfuji.
