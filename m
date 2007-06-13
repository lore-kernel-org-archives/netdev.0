From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Realtek r8168 slow outbound transfer -  potential fix/workaround
Date: Thu, 14 Jun 2007 01:11:24 +0200
Message-ID: <20070613231124.GC22521@electric-eye.fr.zoreil.com>
References: <4670032C.7010803@iinet.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Gundersen <gundy@iinet.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:59913 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753502AbXFMXM4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2007 19:12:56 -0400
Content-Disposition: inline
In-Reply-To: <4670032C.7010803@iinet.net.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Gundersen <gundy@iinet.net.au> :
[...]
> I've been doing a bit of investigation work into a problem that I've 
> been experiencing with the latest available r8168 driver from realtek 
> ('r8168-8.001.00') & linux kernel 2.6.21.1.
> 
> I have been experiencing wierd problems with slow outbound traffic that 
> seem to go away if there's traffic coming into the device.  Googling 
> seen reports of this in a number of places on the web so I get the 
> feeling I'm not alone.

What is the value of the MTU for your 8168 device ?

-- 
Ueimor
