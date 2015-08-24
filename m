From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Mon, 24 Aug 2015 14:20:23 +1000
Message-ID: <20150824142023.11355647@canb.auug.org.au>
References: <20150824132111.534ddea7@canb.auug.org.au>
	<20150823.203325.2208394271706147325.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, jbenc@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150823.203325.2208394271706147325.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

On Sun, 23 Aug 2015 20:33:25 -0700 (PDT) David Miller <davem@davemloft.net> wrote:
>
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Mon, 24 Aug 2015 13:21:11 +1000
> 
> > After merging the net-next tree, today's linux-next build (arm
> > multi_v7_defconfig) failed like this:
> 
> Fixed by:
> 
> ====================
> [PATCH] route: fix breakage after moving lwtunnel state

Thanks, I will get that tomorrow.  I must try to remember to check to
see if you have added fixes to your tree when I get these errors (not
that it happens all that often).

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
