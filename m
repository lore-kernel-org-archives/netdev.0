From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: tc ipt action
Date: Sun, 16 Dec 2012 22:21:19 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1212162220270.20281@nerf07.vanv.qr>
References: <50C4821D.5090206@gmail.com> <50C9B4BB.9060609@mojatatu.com> <50CCE961.5050204@mojatatu.com> <20121216002755.GA11773@1984> <alpine.LNX.2.01.1212160144110.26218@nerf07.vanv.qr> <50CDA5BE.2080800@mojatatu.com> <alpine.LNX.2.01.1212161815310.27614@nerf07.vanv.qr>
 <50CE0921.7060306@mojatatu.com> <alpine.LNX.2.01.1212161850530.27614@nerf07.vanv.qr> <50CE307E.40304@mojatatu.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Yury Stankevich <urykhy@gmail.com>, shemonc@gmail.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <50CE307E.40304@mojatatu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 2012-12-16 21:35, Jamal Hadi Salim wrote:

>> 	git://git.inai.de/linux xt2-pktsched
>> commit 42c559c148cbbc22bf2cc29f2ad08bc330891838
>
> I'll look at it later - very slow connection at the moment so cloning will take
> a while.

If you have a preexisting clone of any linux tree, you can utilize
`git remote add ...` to only grab the deltas.
