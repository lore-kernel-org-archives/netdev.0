From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: fix neigh_resolve_output can cause skb_under_panic
Date: Mon, 1 Oct 2012 19:00:40 +0100
Message-ID: <1349114440.2577.26.camel@bwh-desktop.uk.solarflarecom.com>
References: <CA3E5132752D1F49871ED0FC40D56BBA43ECE2E72D@EUSAACMS0701.eamcs.ericsson.se>
	 <20120928235209.GA11474@kroah.com>
	 <CA3E5132752D1F49871ED0FC40D56BBA43ECE2E743@EUSAACMS0701.eamcs.ericsson.se>
	 <20120929005721.GA13335@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ramesh Nagappa <ramesh.nagappa@ericsson.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"michel@digirati.com.br" <michel@digirati.com.br>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120929005721.GA13335@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-09-28 at 17:57 -0700, gregkh@linuxfoundation.org wrote:
[...]
> > > You need a blank line before the first Signed-off-by: line.  
> > > Surely one of the reviewers should have caught this basic thing?
> > 
> > Outlook mangled the patch. I am unable to use git send-email because of
> > a corporate firewall on the build machine.
> 
> Then your patch would also be corrupted, Outlook, and Exchange, can not
> handle patches at all.  Please read Documentation/email_clients.txt for
> more details.
> 
> Also, ask your coworkers who properly submit patches what they do to
> work around your broken email infrastructure.

I successfully send patches using git-imap-send and Evolution talking to
Exchange 2010 through its IMAP and SMTP submission interfaces.  (I think
the previous version worked as well.)  But I would agree that Outlook is
probably hopeless.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
