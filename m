From: David Miller <davem@davemloft.net>
Subject: Re: ip_rt_bug questions.
Date: Tue, 19 Apr 2011 12:22:08 -0700 (PDT)
Message-ID: <20110419.122208.229738227.davem@davemloft.net>
References: <20110418215922.GA17818@redhat.com>
	<20110418.220419.226797064.davem@davemloft.net>
	<20110419181322.GA2034@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46170
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753145Ab1DSTWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 15:22:43 -0400
In-Reply-To: <20110419181322.GA2034@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Tue, 19 Apr 2011 14:13:22 -0400

> So I hit that twice in the same hour yesterday, but haven't been
> able to reproduce it since.  My fuzzer must have been dependant
> upon something I can't influence (memory contents perhaps, I pass
> around random pointers).
> 
> I'll keep the WARN_ON in there in case I do stumble across it again.

Maybe it only triggers when a certain combination of your analog synths
are turned on?
