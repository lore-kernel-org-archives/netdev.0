From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH] PHYLIB: IRQ event workqueue handling fixes
Date: Fri, 21 Sep 2007 13:51:12 +0100 (BST)
Message-ID: <Pine.LNX.4.64N.0709211334420.2724@blysk.ds.pg.gda.pl>
References: <Pine.LNX.4.64N.0709171750220.17606@blysk.ds.pg.gda.pl>
 <20070920165348.0b25be3d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andy Fleming <afleming@freescale.com>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cerber.ds.pg.gda.pl ([153.19.208.18]:40809 "EHLO
	cerber.ds.pg.gda.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755212AbXIUMvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 08:51:25 -0400
In-Reply-To: <20070920165348.0b25be3d.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 20 Sep 2007, Andrew Morton wrote:

> You always put boring, crappy, insufficient text in the for-the-changelog
> section and interesting, useful, sufficient text in the not-for-the-changelog
> section.

 I'll swap the sections in the future then. ;-)  Frankly I was not sure 
whether the changelog was happy about being fed with lengthy explanations 
and it has not spoken out.

 I have to admit this is a habit carried over from the FSF-style ChangeLog 
-- where the enforced rule is actually *not* to provide any explanation 
for why changes are done and only describe what has been modified (with 
any discussion around archived in the respective mailing list).

> But you can't fool me!  I have an editor and I fix it up.

 Thank you and sorry for the extra work I caused you -- I shall keep your 
suggestion in mind in the future.

  Maciej
