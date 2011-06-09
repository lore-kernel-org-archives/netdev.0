From: Greg K-H <greg@kroah.com>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Wed, 8 Jun 2011 22:17:55 -0700
Message-ID: <7CA9E653-DABC-470C-BCA6-905D6EBF9283@kroah.com>
References: <20110609145657.96fae0d0.sfr@canb.auug.org.au>
Mime-Version: 1.0 (iPad Mail 8J2)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Alexey Dobriyan <adobriyan@gmail.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110609145657.96fae0d0.sfr@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Jun 8, 2011, at 9:56 PM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:

> Hi all,
> 
> After merging the net tree, today's linux-next build (x86_64 allmodconfig)
> failed like this:
> 
> [See summary in patch below.]
> 
> [Hmmm, suddenly allmodconfig is building stuff in staging?  Ah ha!
> Commit fe35a59e16fb ("Staging: remove STAGING_EXCLUDE_BUILD
> option")  Greg, a bit of warning might have been nice :-( ]
> 

Sorry, this is something that Linus asked for and will be going to him
tomorrow with the rest of the staging-linus branch.

greg k-h
