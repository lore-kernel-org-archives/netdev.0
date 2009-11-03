From: =?iso-8859-1?Q?Fran=E7ois?= romieu <romieu@zoreil.com>
Subject: Re: [PATCH] r8169: partial support and phy init for the 8168d
Date: Tue, 3 Nov 2009 09:01:21 +0100
Message-ID: <20091103080120.GA27237@zoreil.com>
References: <20091007224420.GA20170@electric-eye.fr.zoreil.com> <1257092683.3136.325.camel@localhost> <20091101.224645.262714217.davem@davemloft.net> <20091102190618.GM4236@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	edward_hsu@realtek.com.tw
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pulsar.zoreil.com ([83.167.33.49]:37636 "EHLO pulsar.zoreil.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751220AbZKCIJf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Nov 2009 03:09:35 -0500
Content-Disposition: inline
In-Reply-To: <20091102190618.GM4236@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Mon, Nov 02, 2009 at 07:06:18PM +0000, Ben Hutchings wrote :
> > 
> > You don't know if it's machine code or some data values that
> > are used to control the PHY's execution.
> 
> No, I don't know that this is machine code.  But you are setting up
> a false opposition: 'data values that are used to control the PHY's
> execution' certainly include the machine code that it executes.

I'll forward the thread to the new maintainer at Realtek since Edward works
on different topics now and ask him for a clarification, ok ?

-- 
Ueimor
