From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Check if user has CAP_NET_ADMIN to change congestion
 control algorithm
Date: Thu, 26 Oct 2006 17:02:21 -0700 (PDT)
Message-ID: <20061026.170221.99202188.davem@davemloft.net>
References: <4540F076.70801@psc.edu>
	<20061026224407.GA2018@c3po.0xdef.net>
	<20061026235256.GB2018@c3po.0xdef.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jheffner@psc.edu, shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:38075
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1946037AbWJ0ACl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Oct 2006 20:02:41 -0400
To: hagen@jauu.net
In-Reply-To: <20061026235256.GB2018@c3po.0xdef.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This is driving me crazy...

Your email client turned the tabs into spaces in the patch making it
useless.

I want to ask why it is so hard for people to submit patches that are
not corrupted?  :-/

I type in this kind of email response at least 2 or 3 times every
single day that I review patches.  Spending the time to review a patch
only to find out that it is corrupted and doesn't apply consumes a
significant chunk of my time.

Again, send the patch in an email to yourself and try to apply the
patch from that email if you are in doubt.
