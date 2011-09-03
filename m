From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: [next] unix stream crashes
Date: Sat, 03 Sep 2011 08:23:46 +0200
Message-ID: <4E61C7F2.3090902@gmail.com>
References: <4E5FEF28.60406@gmail.com> <3179.1314924559@turing-police.cc.vt.edu> <1314927645.2576.2939.camel@schen9-DESK> <6805.1314979936@turing-police.cc.vt.edu> <1315007703.2576.2965.camel@schen9-DESK> <6043.1315028115@turing-police.cc.vt.edu> <CA+icZUVuJWpLquLk4kHJzmMKtPw24oxud=u3Na0U0HhSYqwV1w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sedat Dilek <sedat.dilek@googlemail.com>, Valdis.Kletnieks@vt.edu,
	Tim Chen <tim.c.chen@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	ML netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>
To: sedat.dilek@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+icZUVuJWpLquLk4kHJzmMKtPw24oxud=u3Na0U0HhSYqwV1w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/03/2011 07:54 AM, Sedat Dilek wrote:
> I saw similiar call-traces with put_cred_rcu() - besides with
> kmem_cache_alloc_trace().
> My post-it says:
> Kernel panic - not syncing: CRED: put_cred_rcu sees f67ac0c0 with usage -43

Hm, Tim, it looks like you put a pid which you did not get?

regards,
-- 
js
