From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Re: [PATCH 0/14] prism54: bring up to sync with
 prism54.org cvs rep
Date: Thu, 27 May 2004 15:24:51 -0400
Sender: prism54-devel-admin@prism54.org
Message-ID: <40B64083.9050200@pobox.com>
References: <20040524083003.GA3330@ruslug.rutgers.edu>	<40B63132.4050906@pobox.com>	<20040527182531.GA8942@scowler.net>	<40B63639.6080705@pobox.com> <20040527120544.2fbd4b35.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: schizo@debian.org, mcgrof@studorgs.rutgers.edu,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
	prism54-devel@prism54.org, debian-kernel@lists.debian.org
Return-path: <prism54-devel-admin@prism54.org>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20040527120544.2fbd4b35.akpm@osdl.org>
Errors-To: prism54-devel-admin@prism54.org
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Post: <mailto:prism54-devel@prism54.org>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel/>
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> Jeff Garzik <jgarzik@pobox.com> wrote:
> 
>> Luis, you, or somebody should create a new patch series with just the 
>> critical fixes, NO WHITESPACE/FORMATTING CHANGES mixed in, and send 
>> those first.
> 
> 
> Whitespace changes are often nice, but they should be the very first
> patch[es] in the series.  You should be able to verify that the .o file was
> unchanged before and after.

Very first, or very last.  I leave that up to the maintainer.


> That way they become a no-brainer and it becomes easier to review and
> understand the substantive changes.

Agreed.

Further, when someone mixes an Lindent in with functional changes, I 
become very suspicious.  That is precisely the method that certain high 
profile Linux hackers have used in the past to intentionally obfuscate 
security changes.

	Jeff
