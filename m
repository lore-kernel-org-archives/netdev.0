From: David Miller <davem@davemloft.net>
Subject: Re: [REGRESSION] 2.6.24-rc7: e1000: Detected Tx Unit Hang
Date: Thu, 17 Jan 2008 00:00:02 -0800 (PST)
Message-ID: <20080117.000002.37027317.davem@davemloft.net>
References: <36D9DB17C6DE9E40B059440DB8D95F520432DA91@orsmsx418.amr.corp.intel.com>
	<20080116.232037.261622584.davem@davemloft.net>
	<200801170851.56029.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, slavon@bigtelecom.ru,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: elendil@planet.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48887
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752925AbYAQIAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2008 03:00:04 -0500
In-Reply-To: <200801170851.56029.elendil@planet.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frans Pop <elendil@planet.nl>
Date: Thu, 17 Jan 2008 08:51:55 +0100

> On Thursday 17 January 2008, David Miller wrote:
> > From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
> >
> > > We spent Wednesday trying to reproduce (without the patch) these issues
> > > without much luck, and have applied the patch cleanly and will continue
> > > testing it.  Given the simplicity of the changes, and the community
> > > testing, I'll give my ack and we will continue testing.
> >
> > You need a slow CPU, and you need to make sure you do actually
> > trigger the TX limiting code there.
> 
> Hmmm. Is a dual core Pentium D 3.20GHz considered slow these days?

No of course :-)  I guess it therefore depends upon the load
as well.
