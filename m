From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Subject: Re: 2.6.22-git: known regressions with patches
Date: Thu, 19 Jul 2007 21:21:08 +0200
Message-ID: <200707192121.08869.bzolnier@gmail.com>
References: <469F92B8.5090809@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Giacomo Catenazzi <cate@cateee.net>,
	Jens Axboe <jens.axboe@oracle.com>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Jan Engelhardt <jengelh@linux01.gwdg.de>,
	Jens Axboe <axboe@suse.de>,
	"Peter M. Jones" <pjones@redhat.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	"=?utf-8?q?S=2E=C3=87a=C4=9Flar?= Onur" <caglar@pardus.org.tr>,
	Meelis Roos <mroos@linux.ee>,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	David Howells <dhowells@redhat.com>, netdev@vger.kernel.org,
	Randy Dunlap <randy.dunlap@oracle.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:54026 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755102AbXGSTK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 15:10:59 -0400
Received: by ug-out-1314.google.com with SMTP id j3so474035ugf
        for <netdev@vger.kernel.org>; Thu, 19 Jul 2007 12:10:57 -0700 (PDT)
In-Reply-To: <469F92B8.5090809@googlemail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

On Thursday 19 July 2007, Michal Piotrowski wrote:

> Unclassified
> 
> Subject         : disk error loop (panic?) ide_do_rw_disk-bad
> References      : http://lkml.org/lkml/2007/7/17/467
> Last known good : ?
> Submitter       : Giacomo Catenazzi <cate@cateee.net>
> Caused-By       : ?
> Handled-By      : Jens Axboe <jens.axboe@oracle.com>
>                   Linus Torvalds <torvalds@linux-foundation.org>
>                   Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
> Patch           : http://lkml.org/lkml/2007/7/19/26
> Status          : patch available

Additional patch is an improvement but the regression itself has already
been fixed in the mainline (by reverting problematic changes).

Thanks,
Bart
