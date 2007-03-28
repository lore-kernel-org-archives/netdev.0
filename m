From: Alan Cox <alan@redhat.com>
Subject: Re: Patch:replace with time_after in drivers/net/eexpress.c
Date: Wed, 28 Mar 2007 04:46:20 -0400
Message-ID: <20070328084620.GB21357@devserv.devel.redhat.com>
References: <1175058871.11584.33.camel@shani-win>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: philb@gnu.org, alan@redhat.com, netdev@vger.kernel.org,
	kernel-janitors@osdl.org
To: Shani <shani.moideen@wipro.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:51022 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753250AbXC1Iqb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2007 04:46:31 -0400
Content-Disposition: inline
In-Reply-To: <1175058871.11584.33.camel@shani-win>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 28, 2007 at 10:44:31AM +0530, Shani wrote:
> Hi,
> 
> Replacing with time_after in drivers/net/eexpress.c
> Applies and compiles clean on latest tree.Not tested.
> 
> thanks.
> 
> Signed-off-by: Shani Moideen <shani.moideen@wipro.com>

NAK as not tested. The existing code is known to work so ugly or not
it is better than untested changes


