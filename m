From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [PATCH 2/3] cgroups: Add an API to attach a task to current task's
 cgroup
Date: Mon, 31 May 2010 09:07:13 +0800
Message-ID: <4C030BC1.6000607@cn.fujitsu.com>
References: <20100527091426.GA6308@redhat.com> <20100527124448.GA4241@redhat.com> <20100527131254.GB7974@redhat.com> <4BFE9ABA.6030907@kernel.org> <20100527163954.GA21710@redhat.com> <4BFEA434.6080405@kernel.org> <20100527173207.GA21880@redhat.com> <4BFEE216.2070807@kernel.org> <20100528150830.GB21880@redhat.com> <4BFFE742.2060205@kernel.org> <20100530112925.GB27611@redhat.com> <4C02C987.6020805@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Oleg Nesterov <oleg@redhat.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dmitri Vorobiev <dmitri.vorobiev@movial.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C02C987.6020805@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

04:24, Tejun Heo wrote:
> From: Sridhar Samudrala <samudrala.sridhar@gmail.com>
> 
> Add a new kernel API to attach a task to current task's cgroup
> in all the active hierarchies.
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Acked-by: Li Zefan <lizf@cn.fujitsu.com>

btw: you lost the reviewed-by tag given by Paul Menage.
