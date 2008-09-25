From: Marcel Holtmann <holtmann@linux.intel.com>
Subject: Re: pull request: wireless-2.6 2008-09-24
Date: Thu, 25 Sep 2008 21:09:01 +0200
Message-ID: <1222369742.6442.0.camel@californication>
References: <20080924231720.GD3639@tuxdriver.com>
	 <1222321622.2510.455.camel@debian.sh.intel.com>
	 <20080925114133.GA5044@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Zhu Yi <yi.zhu@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754617AbYIYRIV@vger.kernel.org>
In-Reply-To: <20080925114133.GA5044@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi John,

> > > One more for 2.6.27 -- a fix for a possible interrupt storm.  There is
> > > even a link in the commit log to a youtube video of the storm in
> > > progress. :-)
> > > 
> > > Let me know if there are problems!
> > 
> > Can you also add this one? It doesn't panic the kernel when a frame from
> > firmware is invalid.
> > 
> > http://marc.info/?l=linux-wireless&m=122219037706528&w=2
> 
> Is there an open bug report for that anywhere?  Is this something
> that real users (no offense to Johannes) are likely to hit?

I was hitting this one a frequent basis on a 64-bit Linux running on an
off-the-shelf X61.

Regards

Marcel
