From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: Re: [NFS] [RFC: 2.6 patch] net/sunrpc/: possible cleanups
Date: Sat, 15 Apr 2006 19:01:06 -0400
Message-ID: <C066F372.7D70%Charles.Lever@netapp.com>
References: <20060415213215.GN15022@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <neilb@cse.unsw.edu.au>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	<nfs@lists.sourceforge.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12431 "EHLO mx2.netapp.com")
	by vger.kernel.org with ESMTP id S932515AbWDOXBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Apr 2006 19:01:14 -0400
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20060415213215.GN15022@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/15/06 5:32 PM, "Adrian Bunk" <bunk@stusta.de> wrote:

> On Thu, Oct 06, 2005 at 07:13:14AM -0700, Lever, Charles wrote:
> 
>> actually, can we hold off on this change?  the RPC transport switch will
>> eventually need most of those EXPORT_SYMBOLs.
>> ...
>>> This patch was already sent on:
>>> - 30 May 2005
>>> - 7 May 2005
>> ...
> 
> One year has passed since I sent this patch the first time, and with the
> exception that it needs re-diff'ing it still applies.
> 
> Charles, are the changes you are talking about that might need them
> available in the very near future?

Yes, they are coming soon.
