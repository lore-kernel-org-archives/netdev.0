From: Andreas Dilger <adilger@clusterfs.com>
Subject: Re: CVS tags (was  Re: [Prism54-devel] Re: [PATCH 4/14 linux-2.6.7-rc1] prism54: add support for avs header in
Date: Thu, 27 May 2004 14:01:59 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040527200159.GP2603@schnapps.adilger.int>
References: <20040524083146.GE3330@ruslug.rutgers.edu> <40B631B3.4000902@pobox.com> <20040527191649.GT3330@ruslug.rutgers.edu> <200405271931.i4RJVjYB002642@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>,
        Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        prism54-devel@prism54.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Valdis.Kletnieks@vt.edu
Content-Disposition: inline
In-Reply-To: <200405271931.i4RJVjYB002642@turing-police.cc.vt.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On May 27, 2004  15:31 -0400, Valdis.Kletnieks@vt.edu wrote:
> On Thu, 27 May 2004 15:16:49 EDT, Luis R. Rodriguez said:
> > --- ksrc/islpci_eth.c
> > +++ ksrc-new/islpci_eth.c
> 
> I think this was what he referred to:
> 
> >-/*  $Header: /var/lib/cvs/prism54-ng/ksrc/islpci_eth.c,v 1.31 2004/03 15:27:44 ajfa Exp $
> >+/*  $Header: /var/lib/cvs/prism54-ng/ksrc/islpci_eth.c,v 1.33 2004/03/19 23:03:58 ajfa Exp $
> 
> as this will almost surely cause rejects (sooner or later) unless 100% of your
> patches are applied and in the right order.

This also causes grief if this file is ever imported again into a CVS-based
SCM, unless you remember to do so with -ko.

Cheers, Andreas
--
Andreas Dilger
http://sourceforge.net/projects/ext2resize/
http://www-mddsp.enel.ucalgary.ca/People/adilger/
