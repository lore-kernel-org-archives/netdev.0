From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the tip tree with the net-next tree
Date: Wed, 1 Nov 2017 21:57:10 +1100
Message-ID: <20171101215710.3f222e70@canb.auug.org.au>
References: <20171101181554.1826e8c8@canb.auug.org.au>
        <20171101081832.zdehp7ysi5ecwsdv@hirez.programming.kicks-ass.net>
        <20171101082742.dteg337holmodzn2@gmail.com>
        <20171101085524.4dcxgaq7kawn37pq@hirez.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@kernel.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Yonghong Song <yhs@fb.com>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20171101085524.4dcxgaq7kawn37pq@hirez.programming.kicks-ass.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Peter,

On Wed, 1 Nov 2017 09:55:24 +0100 Peter Zijlstra <peterz@infradead.org> wrote:
>
> Hmm, I thought having that same base patch in both trees would allow it
> to resolve that conflict. A well..

There is a difference between having he same patch and the same commit ...

-- 
Cheers,
Stephen Rothwell
