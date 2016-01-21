From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: sock: remove dead cgroup methods from struct proto
Date: Thu, 21 Jan 2016 22:30:31 +0300
Message-ID: <56A131D7.4040102@cogentembedded.com>
References: <1453402871-2548-1-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
To: Johannes Weiner <hannes@cmpxchg.org>,
 "David S. Miller" <davem@davemloft.net>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1453402871-2548-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Hello.

On 01/21/2016 10:01 PM, Johannes Weiner wrote:

> The cgroup methods are no longer used after baac50b ("net:

    12-digit ID is now enforced by scripts/checkpatch.pl.

> tcp_memcontrol: simplify linkage between socket and page counter").
> The hunk to delete them was included in the original patch but must
> have gotten lost during conflict resolution on the way upstream.
>
> Fixes: baac50b ("net: tcp_memcontrol: simplify linkage between socket and page counter")

    Here as well.

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
[...]

MBR, Sergei


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
