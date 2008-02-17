From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH] New device for DM9601 usb net driver
Date: Sun, 17 Feb 2008 20:36:22 +0100
Message-ID: <873arrz87d.fsf@macbook.be.48ers.dk>
References: <Pine.LNX.4.64.0802071046540.24824@castor.opentrend.net>
	<874pcgy56v.fsf@macbook.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: Robert Brockway <robert@timetraveller.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.186]:62499 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751847AbYBQTge (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Feb 2008 14:36:34 -0500
Received: by mu-out-0910.google.com with SMTP id i10so1287113mue.5
        for <netdev@vger.kernel.org>; Sun, 17 Feb 2008 11:36:32 -0800 (PST)
In-Reply-To: <874pcgy56v.fsf@macbook.be.48ers.dk> (Peter Korsgaard's message of "Sun\, 10 Feb 2008 20\:36\:24 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Peter" == Peter Korsgaard <jacmet@sunsite.dk> writes:

>>>>> "Robert" == Robert Brockway <robert@timetraveller.org> writes:
 Robert> Hi Peter.  I've verified that the Hirose USB-100 (0x0a47,
 Robert> 0x9601) is a clone of the DAVICOM DM9601.  I patched dm9601.c
 Robert> to identify this device and now have these in production.
 Robert> Unified diff against 2.6.24 attached.

 Peter> Thanks!

Could you resend with a proper Signed-off-by: line? (you can add my acked-by)

 Peter> Acked-by: Peter Korsgaard <jacmet@sunsite.dk>

-- 
Bye, Peter Korsgaard
