From: Ajit <ajitsa_bes@yahoo.com>
Subject: Re: Maximum no of bytes Ethernet can transfer at a time ??
Date: Wed, 27 Apr 2011 12:27:26 +0000 (UTC)
Message-ID: <loom.20110427T142551-736@post.gmane.org>
References: <loom.20110427T140651-957@post.gmane.org> <1303906910.3166.50.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:46458 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757571Ab1D0M1i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Apr 2011 08:27:38 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1QF3qD-0007Cl-Jj
	for netdev@vger.kernel.org; Wed, 27 Apr 2011 14:27:37 +0200
Received: from mumbai-123-5.primenet.in ([203.115.123.5])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2011 14:27:37 +0200
Received: from ajitsa_bes by mumbai-123-5.primenet.in with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2011 14:27:37 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet <at> gmail.com> writes:

> Sure, check your syscall returns values, and search for SO_RCVBUF &
> SO_SNDBUF   (man 7 socket)
> 
> --

okies..I dont know exactly how to use those but I will google and try it..
will post my result after some time.

Thank you


