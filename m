From: Sami Farin <safari-kernel@safari.iki.fi>
Subject: Re: updated tcatm patches for kernel/iproute 2.6.22
Date: Thu, 19 Jul 2007 14:35:59 +0300
Message-ID: <20070719113559.4y2z4bj4vwtglupw@m.safari.iki.fi>
References: <20070718210638.bs44zz4veowqf2kr@m.safari.iki.fi> <469E9B24.2080002@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Linux Networking Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pne-smtpout3-sn1.fre.skanova.net ([81.228.11.120]:44087 "EHLO
	pne-smtpout3-sn1.fre.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756027AbXGSMp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 08:45:56 -0400
Received: from safari.iki.fi (80.223.106.128) by pne-smtpout3-sn1.fre.skanova.net (7.2.075)
        id 46758C5300119AD9 for netdev@vger.kernel.org; Thu, 19 Jul 2007 13:36:00 +0200
Content-Disposition: inline
In-Reply-To: <469E9B24.2080002@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 19, 2007 at 00:58:44 +0200, Patrick McHardy wrote:
> Sami Farin wrote:
> > I had used tcatm patch with 2.6.16 kernel and I was
> > happy with it.
> > Now I patched Linux kernel 2.6.22 and iproute-2.6.22
> > for tcatm.  Seems to work (TM).  Only HTB tested.
> 
> 
> Let me repeat again before we get in an endless discussion
> again - I will NACK these patches until we have a solution
> that works for all qdiscs.

I googled for
"Accurate packet scheduling for ATM" mchardy
and found some threads from 2006.

http://www.mail-archive.com/netdev@vger.kernel.org/msg15706.html
http://www.mail-archive.com/netdev@vger.kernel.org/msg21395.html

So, Patrick:
1) what is this "solution"?  do you have code?
   or a brief explanation...
2) are you still working on this?
   is somebody else?
3) do you have patches for iproute/kernel 2.6.22?
4) if you have some patches, but they are not yet
   complete, what else needs to be done?

-- 
Do what you love because life is too short for anything else.

