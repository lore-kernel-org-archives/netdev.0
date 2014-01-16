From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 1/6] net: allow > 0 order atomic page alloc
	in skb_page_frag_refill
Date: Thu, 16 Jan 2014 15:28:00 -0800 (PST)
Message-ID: <20140116.152800.901405996505782677.davem@davemloft.net>
References: <1389901950-3854-1-git-send-email-mwdalton@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, edumazet@google.com,
	bhutchings@solarflare.com
To: mwdalton@google.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1389901950-3854-1-git-send-email-mwdalton@google.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


All 6 patches applied.

Next time, PLEASE, give me a header email ala "[PATCH net-next v4 0/6]" giving
a broad overview of the series.

This serves several purposes.

First, it gives me a single top-level email to reply to when I want to let
you know that I've either applied or rejected this series.  Because you
didn't provide a header posting, I have to pick an arbitrary one of
the patches to use for this purpose as I have done here.

Second, it gives a place for you to describe at a high level what the patch
series is doing.  I create dummy merge commits and place that descriptive
text into it, so that anyone else looking at the GIT history can see that
these patches go together as a coherent unit and what that unit is trying
to achieve.

Thanks.
