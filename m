From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH] eth1394: endian fixes
Date: Sat, 10 Jun 2006 18:46:10 +0200
Message-ID: <448AF752.5070109@s5r6.in-berlin.de>
References: <20060519132539.GC17751@mipter.zuzino.mipt.ru> <44782474.9050304@s5r6.in-berlin.de> <20060527161249.GA7276@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:16844 "EHLO
	einhorn.in-berlin.de") by vger.kernel.org with ESMTP
	id S1751650AbWFJQs4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Jun 2006 12:48:56 -0400
To: Alexey Dobriyan <adobriyan@gmail.com>
In-Reply-To: <20060527161249.GA7276@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote on 2006-05-27:
> On Sat, May 27, 2006 at 12:05:40PM +0200, Stefan Richter wrote:
>> Did you have the chance to test your patch on different
>> platforms and with different peer OSs/platforms?
> 
> Unfortunately not.

The patch works OK on an x86/Linux host with x86/WinXP peer and 
ppc32/OSX peer. Thanks,
-- 
Stefan Richter
-=====-=-==- -==- -=-=-
http://arcgraph.de/sr/
