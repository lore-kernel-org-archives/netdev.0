From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Re: [PATCH 0/14] prism54: bring up to sync with
 prism54.org cvs rep
Date: Thu, 27 May 2004 14:40:57 -0400
Sender: prism54-devel-admin@prism54.org
Message-ID: <40B63639.6080705@pobox.com>
References: <20040524083003.GA3330@ruslug.rutgers.edu> <40B63132.4050906@pobox.com> <20040527182531.GA8942@scowler.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <mcgrof@ruslug.rutgers.edu>,
	Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com, prism54-devel@prism54.org,
	debian-kernel@lists.debian.org
Return-path: <prism54-devel-admin@prism54.org>
To: Clint Adams <schizo@debian.org>
In-Reply-To: <20040527182531.GA8942@scowler.net>
Errors-To: prism54-devel-admin@prism54.org
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Post: <mailto:prism54-devel@prism54.org>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel/>
List-Id: netdev.vger.kernel.org

Clint Adams wrote:
>>>[PATCH 8/14 linux-2.6.7-rc1] prism54: Fix prism54.org bugs 39, 73
> 
> 
>>I'm considering rejecting the entire series because of this obfuscation 
>>of changes, and getting you to resend with the whitespace crapola 
>>separated out.
> 
> 
> Please at least apply the changes in the "8/14" patch, because without
> them the driver is unusable on big-endian architectures.


The entire patch series was dropped.

Luis, you, or somebody should create a new patch series with just the 
critical fixes, NO WHITESPACE/FORMATTING CHANGES mixed in, and send 
those first.

	Jeff
