From: Kasper Sandberg <lkml@metanurb.dk>
Subject: Re: [Announce] Intel PRO/Wireless 3945ABG Network Connection
Date: Fri, 03 Mar 2006 21:04:27 +0100
Message-ID: <1141416267.17837.1.camel@localhost>
References: <43FF88E6.6020603@linux.intel.com>
	 <20060225084139.GB22109@infradead.org>
	 <1140915482.23286.6.camel@localhost.localdomain>
	 <20060227171029.GA763@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	James Ketrenos <jketreno@linux.intel.com>,
	NetDev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
	okir@suse.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932326AbWCCUEj@vger.kernel.org>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20060227171029.GA763@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-02-27 at 17:10 +0000, Christoph Hellwig wrote:
> On Sun, Feb 26, 2006 at 12:58:02AM +0000, Alan Cox wrote:
> > On Sad, 2006-02-25 at 08:41 +0000, Christoph Hellwig wrote:
> > > the regualatory problems are not true.  
> > 
> > They are although the binary interpretation isn't AFAIK from law but
> > from lawyers. The same is actually true in much of the EU. The actual
> > requirement is that the transmitting device must be reasonably
> > tamperproof. Some of the lawyers have decided that for a software radio
> > tamperproof means "binary".
> 
> Exactly.  There's no strong requirement, it's just over-zealous corporate
> lawyers.  That's why we need to push Intel strongly here.
i completely agree, besides, if this userspace binary blob just does
something to /sys what is to prevent a user from doing that himself?
what is to prevent someone to modify the driver slightly to smash a log
entry every time the daemon does something?

the binary userspace daemon protects against nothing.
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
