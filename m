From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net-next] xen-netback: Follow-up patch for grant mapping
 series
Date: Mon, 24 Mar 2014 10:34:27 +0000
Message-ID: <1395657267.19365.26.camel@kazak.uk.xensource.com>
References: <1395343961-4744-1-git-send-email-zoltan.kiss@citrix.com>
		 <1395343961-4744-2-git-send-email-zoltan.kiss@citrix.com>
	 <1395394872.27358.11.camel@kazak.uk.xensource.com>
	 <532C9389.4040908@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<paul.durrant@citrix.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <532C9389.4040908@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-03-21 at 19:31 +0000, Zoltan Kiss wrote:
> On 21/03/14 09:41, Ian Campbell wrote:
> > On Thu, 2014-03-20 at 19:32 +0000, Zoltan Kiss wrote:
> >> Ian made some late comments about the grant mapping series, I incorporated the
> >> outcomes into this patch. Additional comments, refactoring etc.
> >
> > I don't know how davem feels about merging these kinds of thing into one
> > patch but from my point of view the least thing to do is to enumerate
> > the cleanups -- so that people can verify that the patch does infact do
> > exactly what it says it does, no more, no less.
> Ok, I'll make a detailed list in the commit message about what are the 
> changes, and fix up the typos you mentioned below.

Thanks. Also note Davem's request to split out any real changes from the
pure non-functional cleanups. 

Ian.
