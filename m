From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: e1000e fails probe
Date: Tue, 11 May 2010 10:19:01 -0400
Message-ID: <20100511141850.GG7497@gospo.rdu.redhat.com>
References: <20100510185018.3478bcae@redhat.com> <8DD2590731AB5D4C9DBF71A877482A90010D1DE754@orsmsx509.amr.corp.intel.com> <20100510224308.4334fd11@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Allan, Bruce W" <bruce.w.allan@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Pete Zaitcev <zaitcev@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5376 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758217Ab0EKO0P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 May 2010 10:26:15 -0400
Content-Disposition: inline
In-Reply-To: <20100510224308.4334fd11@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 10, 2010 at 10:43:08PM -0600, Pete Zaitcev wrote:
> On Mon, 10 May 2010 18:33:56 -0700
> "Allan, Bruce W" <bruce.w.allan@intel.com> wrote:
> 
> > Would you be able to try a patch that is already in DaveM's net-next-2.6 tree?  If so, it is http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=commitdiff;h=627c8a041f7aaaea93c766f69bd61d952a277586
> 
> I was too quick to claim victory here. I did an rmmod+insmod,
> it worked. Then I rebooted and it didn't. Weird...
> 

That is exactly what I used to see on what I think is a similar system
to Pete's.  Pete and I have been talking and it looks like this system
may need a BIOS update, so I'll see if we can work to get him an updated
one.

