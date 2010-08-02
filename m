From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH repost] sched: export sched_set/getaffinity to modules
Date: Mon, 2 Aug 2010 17:02:06 +0200
Message-ID: <20100802150206.GA10218@redhat.com>
References: <1277996135.1917.198.camel@laptop> <4C2E2987.9040702@us.ibm.com> <1278094270.1917.288.camel@laptop> <20100702210637.GA12433@redhat.com> <20100726171230.GA27644@redhat.com> <1280166688.3375.5.camel@localhost> <20100726180834.GA26988@redhat.com> <20100727154155.GA13419@redhat.com> <20100730141901.GA9076@redhat.com> <20100801085022.GD16158@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dmitri Vorobiev <dmitri.vorobiev@movial.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Thomas Gleixner <tglx@linutronix.de>,
	Andi Kleen <ak@linux.intel.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100801085022.GD16158@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/01, Michael S. Tsirkin wrote:
>
> Oleg, I mean Ack the exporting of get/set affinity.

Ah, I misunderstood.

Yes, I believe the exporting is the lesser evil. Please feel free
to add my ack.

Oleg.
