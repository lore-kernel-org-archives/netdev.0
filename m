From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 00/11] The _entire_ secid reconciliation patchset (tada!)
Date: Mon, 09 Oct 2006 16:30:13 -0400
Message-ID: <452AB155.8070409@hp.com>
References: <20061009194223.402695000@hp.com> <Pine.LNX.4.64.0610091612140.31187@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov, Venkat Yekkirala <vyekkirala@TrustedCS.com>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Eric Paris <eparis@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:34735 "EHLO atlrel9.hp.com")
	by vger.kernel.org with ESMTP id S964819AbWJIUaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2006 16:30:17 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0610091612140.31187@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris wrote:
> On Mon, 9 Oct 2006, paul.moore@hp.com wrote:
> 
>>Please consider this for inclusion into 2.6.20.  If it's too soon to be
>>thinking of 2.6.20 let me know and I'll rebase/resend this patchset once I see
>>notice of David's net-2.6.20 git tree.
> 
> From an initial review of this patchset, it doesn't look quite ready to 
> queue for 2.6.20 (which I plan to to via git once it is).
> 
> Outstanding items include resolving the igmp skb hook issue generally, 
> testing to verify both the design and implementation, and ensuring that 
> all the related policy changes are merged upstream first.

I'll keep the patchset up to date and keep tracking the secid patches (I know
there has been discussion around the IGMP hook this morning).  Once everything
looks okay I'll resend the patchset (with any updates/corrections/etc.) again.

-- 
paul moore
linux security @ hp
