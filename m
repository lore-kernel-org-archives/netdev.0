From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [Uclinux-dist-devel] [PATCH 01/01] smsc911x: fix MAC addresssetting after reset
Date: Mon, 02 Jun 2008 20:38:39 +0200
Message-ID: <87ej7f65sg.fsf@macbook.be.48ers.dk>
References: <OF35F08D73.56884FA4-ON8025744E.0047900A-8025744E.0047BBC0@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Steve.Glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.191]:28927 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751647AbYFBSit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2008 14:38:49 -0400
Received: by mu-out-0910.google.com with SMTP id w8so1192263mue.1
        for <netdev@vger.kernel.org>; Mon, 02 Jun 2008 11:38:44 -0700 (PDT)
In-Reply-To: <OF35F08D73.56884FA4-ON8025744E.0047900A-8025744E.0047BBC0@smsc.com> (Steve Glendinning's message of "Mon\, 19 May 2008 14\:03\:31 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Steve" == Steve Glendinning <Steve.Glendinning@smsc.com> writes:

Hi,

 Steve> (re-sending to netdev in plain text)
 Steve> Hi Michael,

 Steve> I've been maintaining the smsc911x driver out-of-tree, I'll
 Steve> send my latest full patch following this email.  Bill Gatliff
 Steve> already fixed the same MAC address issue, and I've added
 Steve> support for the new LAN9210 and LAN9211 devices.

 Steve> (adding netdev to cc) I'd still like to see this driver
 Steve> replace smc911x in mainline, how does everyone else feel?

I still think it would be better to add new hw support/cleanups to the
existing driver instead of adding a completely new driver.

-- 
Bye, Peter Korsgaard
