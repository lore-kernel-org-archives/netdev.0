From: Andi Kleen <ak@suse.de>
Subject: Re: Virtual device lo asks to queue packet! since -git15
Date: Sat, 21 Jul 2007 23:17:21 +0200
Message-ID: <200707212317.21158.ak@suse.de>
References: <200707210949.22880.ak@suse.de> <20070721.115304.112624318.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:58871 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755159AbXGUVRY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Jul 2007 17:17:24 -0400
In-Reply-To: <20070721.115304.112624318.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 21 July 2007 20:53:04 David Miller wrote:
> From: Andi Kleen <ak@suse.de>
> Date: Sat, 21 Jul 2007 09:49:22 +0200
> 
> > Since -git15 (probably David's merge) I see a lot of 
> > 
> > Virtual device lo asks to queue packet!
> > Virtual device lo asks to queue packet!
> > Virtual device lo asks to queue packet!
> > Virtual device lo asks to queue packet!
> > Virtual device lo asks to queue packet!
> > Virtual device lo asks to queue packet!
> > 
> > during a LTP run on a nfsroot system
> 
> Yes I have a fix pending in my tree for this.

Thanks. Could this explain the firefox hangs too? 

-Andi
