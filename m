From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Re: [2.6.21.1] soft lockup when removing netconsole
 module
Date: Tue, 26 Jun 2007 18:00:00 -0700
Message-ID: <20070626180000.5974e942.akpm@linux-foundation.org>
References: <20070626160753.f86d8803.akpm@linux-foundation.org>
	<7ED098B05D69FE41B380586BF1474DBA441F47@ala-mail08.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Jarek Poplawski" <jarkao2@o2.pl>,
	"Folkert van Heusden" <folkert@vanheusden.com>,
	<linux-kernel@vger.kernel.org>,
	"Thomas Gleixner" <tglx@linutronix.de>, <stable@kernel.org>,
	<netdev@vger.kernel.org>
To: "Wessel, Jason" <jason.wessel@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:39265 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752678AbXF0BBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2007 21:01:32 -0400
In-Reply-To: <7ED098B05D69FE41B380586BF1474DBA441F47@ala-mail08.corp.ad.wrs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 26 Jun 2007 17:46:13 -0700 "Wessel, Jason" <jason.wessel@windriver.com> wrote:

> > >  			}
> > >  		}
> > 
> > Everything went quiet?
> > 
> > If this patch has been tested and fixes the bug, can you 
> > please send a version which is ready for merging?  (ie: add a 
> > suitable description of what it does).
> > 
> > 
> 
> I mailed Jarek separately.
> 
> I had tested the patch with netconsole and kgdb and it does in fact fix
> the problem that was reported.

OK, thanks.  Please don't mail people separately!

I queued this up with a null changelog for now.
