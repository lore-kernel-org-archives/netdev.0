From: Jon Masters <jonathan@jonmasters.org>
Subject: Re: PROBLEM: reproducible crash KVM+nf_conntrack all recent 2.6
 kernels
Date: Thu, 28 Jan 2010 00:59:24 -0500
Message-ID: <1264658364.2793.105.camel@tonnant>
References: <1264657559.2793.103.camel@tonnant>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org
To: linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1264657559.2793.103.camel@tonnant>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-01-28 at 00:46 -0500, Jon Masters wrote:

> A number of people seem to have reported this crash in various forms,
> but I have yet to see a solution, and can reproduce on 2.6.33-rc5 this
> evening so I know it's still present in the latest upstream kernels too.
> Userspace is Fedora 12, and this happens on both all recent F12 kernels
> (sporadic in 2.6.31 until recently, solidly reproducible on 2.6.32) and
> upstream 2.6.32, and 2.6.33-rc5 also - hard to find a "known good".

Now I can capture the panic()s, I'm rebuilding the 2.6.33-rc5 kernel
with some better debugging options to at least get some more data.

Jon.


