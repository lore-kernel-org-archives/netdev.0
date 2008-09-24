From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: D945GCLF  intel atom board & r8169 ethernet broken in
 linux-2.6.27-rc5??
Date: Thu, 25 Sep 2008 00:27:43 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0809250027190.27884@twin.jikos.cz>
References: <9F6ACAE02B6DD040A1E259977622CFDB03F5BCCB@oslexcp1.eu.tandberg.int>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: John Gumb <john.gumb@tandberg.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from twin.jikos.cz ([213.151.79.26]:58856 "EHLO twin.jikos.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752278AbYIXW17 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2008 18:27:59 -0400
In-Reply-To: <9F6ACAE02B6DD040A1E259977622CFDB03F5BCCB@oslexcp1.eu.tandberg.int>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 24 Sep 2008, John Gumb wrote:

> > 01:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8101E
> PCI Express Fast Ethernet controller (rev ff) (prog-if ff)
> >       !!! Unknown header type 7f
> 00: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> 
> 10: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> 
> 20: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> 
> 30: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff  
> 
> Before I load the driver lspci -vvx looks OK.

BTW does by any chance booting with 'nopat' kernel commandline parameter 
fix the problem?

-- 
Jiri Kosina
SUSE Labs

