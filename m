From: Jon Masters <jonathan@jonmasters.org>
Subject: Re: PROBLEM: reproducible crash KVM+nf_conntrack all recent 2.6
 kernels
Date: Fri, 29 Jan 2010 05:57:35 -0500
Message-ID: <1264762655.2793.409.camel@tonnant>
References: <1264657559.2793.103.camel@tonnant>
	 <1264658364.2793.105.camel@tonnant>  <4B6180D1.6050609@trash.net>
	 <1264720891.2793.205.camel@tonnant>  <1264727492.2793.207.camel@tonnant>
	 <1264754565.2793.405.camel@tonnant>
	 <1264756232.3184.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1264756232.3184.10.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2010-01-29 at 10:10 +0100, Eric Dumazet wrote:

> Jon, do you have multiple network namespace active on your machine, when
> crash occurs ?

I don't believe so. I just built in Jason's latest kgdb/kdb patches and
am going to give them a whirl to see if I can get anything more out of
this panic than I currently have.

Jon.


