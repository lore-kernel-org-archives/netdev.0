From: Willy Tarreau <w@1wt.eu>
Subject: Re: [BUG,REGRESSION?] 3.11.6+,3.12: GbE iface rate drops to few KB/s
Date: Wed, 20 Nov 2013 19:29:19 +0100
Message-ID: <20131120182919.GO8581@1wt.eu>
References: <20131112100126.GB23981@1wt.eu> <87vbzxd473.fsf@natisbad.org>
 <20131113072257.GB10591@1wt.eu> <20131117141940.GA18569@1wt.eu>
 <1384710098.8604.58.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131120171227.GG8581@1wt.eu> <20131120173436.GK8581@1wt.eu>
 <1384969222.10637.20.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131120181532.GM8581@1wt.eu>
 <1384971684.10637.22.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 netdev@vger.kernel.org, Arnaud Ebalard <arno@natisbad.org>,
 edumazet@google.com, Cong Wang <xiyou.wangcong@gmail.com>,
 linux-arm-kernel@lists.infradead.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1384971684.10637.22.camel@edumazet-glaptop2.roam.corp.google.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 20, 2013 at 10:21:24AM -0800, Eric Dumazet wrote:
> On Wed, 2013-11-20 at 19:15 +0100, Willy Tarreau wrote:
> 
> > No, I was on latest stable (3.10.19) which exhibits the regression but does
> > not yet have your fix above. Then I tested the patch your proposed in this
> > thread, then this latest one. Since the patch is not yet even in Linus'
> > tree, I'm not sure Arnaud has tried it yet.
> 
> Oh right ;)
> 
> BTW Linus tree has the fix, I just checked this now.
> 
> (Linus got David changes 19 hours ago)

Ah yes I didn't look far enough back.

Thanks,
Willy
