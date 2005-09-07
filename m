From: Patrick McHardy <kaber@trash.net>
Subject: Re: Fw: masquerading failure for at least icmp and tcp+sack on amd64
Date: Thu, 08 Sep 2005 00:08:19 +0200
Message-ID: <431F64D3.5090706@trash.net>
References: <20050907052057.09714a4c.akpm@osdl.org>
	<431EDF78.8060505@trash.net> <20050907213413.GA8222@schmorp.de>
	<431F5EA9.8020601@trash.net> <20050907215407.GC8222@schmorp.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Marc Lehmann <schmorp@schmorp.de>
In-Reply-To: <20050907215407.GC8222@schmorp.de>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Marc Lehmann wrote:
> On Wed, Sep 07, 2005 at 11:42:01PM +0200, Patrick McHardy <kaber@trash.net> wrote:
> 
>>just to give some hints, does this patch make the problem go away?
> 
> I guess now that hw checksumming is identified as the direct cause, this is
> no longer neecssary? If yes, just tell me and I'll try it out.

No, don't bother. I'm goint to trying to figure out what's wrong, your
information so far should be enough, thanks. I'll let you know if I find
something worth trying.
