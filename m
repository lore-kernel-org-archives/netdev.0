From: Shan Wei <shanwei88@gmail.com>
Subject: Re: [PATCH 0/9 v4] use efficient this_cpu_* helper
Date: Fri, 16 Nov 2012 16:30:21 +0800
Message-ID: <50A5F99D.8020503@gmail.com>
References: <50A1A7A9.6050501@gmail.com> <0000013b047079ab-01971b64-07e2-4f2e-a204-6baff2180fc3-000000@email.amazonses.com> <20121115145325.GC7306@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <cl@linux.com>, NetDev <netdev@vger.kernel.org>,
	Kernel-Maillist <linux-kernel@vger.kernel.org>
To: Tejun Heo <htejun@gmail.com>, David Miller <davem@davemloft.net>,
	paulmck@linux.vnet.ibm.com, rostedt@goodmis.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121115145325.GC7306@mtj.dyndns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Tejun Heo:

Tejun Heo said, at 2012/11/15 22:53:
> On Thu, Nov 15, 2012 at 02:19:38PM +0000, Christoph Lameter wrote:
>> Tejon: Could you pick up this patchset?
> 
> Sure, but, Shan, when posting patchset, please make the patches
> replies to the head message; otherwise, it's pretty difficult to track
> what's going on with the patchset as a whole.  I see that some patches
> are being picked up by respective subsystems.  If you have patches
> left, please let me know.

OK, next time i will do as you suggest.

This patchset include more subsystem, i.e network, rcu, trace.
The best way to avoid code conflict is subsystem maintainer to pick them up
to their code tree. I will remind them in each patch that not yet applied and 
add you to the receiver list.

Best Regards
Shan Wei

> 
> Thanks.
> 
