From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: 2.6.22-git: known regressions with patches
Date: Fri, 20 Jul 2007 08:46:32 +0200
Message-ID: <20070720084632.15ea43e9@gondolin.boeblingen.de.ibm.com>
References: <469F92B8.5090809@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Giacomo Catenazzi <cate@cateee.net>,
	Jens Axboe <jens.axboe@oracle.com>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Jan Engelhardt <jengelh@linux01.gwdg.de>,
	Jens Axboe <axboe@suse.de>,
	"Peter M. Jones" <pjones@redhat.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	"=?UTF-8?Q?S.=C3=87a=C4=9Flar?= Onur" <caglar@pardus.org.tr>,
	Meelis Roos <mroos@linux.ee>,
	David Howells <dhowells@redhat.com>, netdev@vger.kernel.org,
	Randy Dunlap <randy.dunlap@oracle.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.uk.ibm.com ([195.212.29.141]:18485 "EHLO
	mtagate8.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754540AbXGTGqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2007 02:46:33 -0400
In-Reply-To: <469F92B8.5090809@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 19 Jul 2007 18:35:04 +0200,
Michal Piotrowski <michal.k.k.piotrowski@gmail.com> wrote:

> FS
> 
> Subject         : AFS compile broken
> References      : http://lkml.org/lkml/2007/7/19/218
> Last known good : ?
> Submitter       : Meelis Roos <mroos@linux.ee>
> Caused-By       : ?
> Handled-By      : Cornelia Huck <cornelia.huck@de.ibm.com>
> Patch           : http://lkml.org/lkml/2007/7/19/223
> Status          : patch available
> 

Multiple people posted this fix, and Andrew's already made it to git
(commit 275afcac9953ece0828972edeab9684cfe1a5ef3).
