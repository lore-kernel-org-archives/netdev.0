From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 26/31] net/sched: use kmemdup rather than duplicating
 its implementation
Date: Fri, 07 Aug 2015 12:35:32 +0200
Message-ID: <55C489F4.9090104@iogearbox.net>
References: <1438934377-4922-1-git-send-email-a.hajda@samsung.com> <1438934377-4922-27-git-send-email-a.hajda@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrzej Hajda <a.hajda@samsung.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438934377-4922-27-git-send-email-a.hajda@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/07/2015 09:59 AM, Andrzej Hajda wrote:
> The patch was generated using fixed coccinelle semantic patch
> scripts/coccinelle/api/memdup.cocci [1].
>
> [1]: http://permalink.gmane.org/gmane.linux.kernel/2014320
>
> Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Not sure where the rest of this series went, but if you want this patch
to be routed via net-next tree (which I recommend, to avoid cross tree
conflicts), then you would need to send these patches separately, rebased
to that tree, and also mention [PATCH net-next XX/YY] in the subject.
                                       ^^^^^^^^
Thanks,
Daniel
