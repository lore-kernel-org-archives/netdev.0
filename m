From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 2/2] enic: Fix Kconfig headline description
Date: Thu, 16 Oct 2008 15:43:02 -0700
Message-ID: <ada3aiwb1qh.fsf@cisco.com>
References: <adaej2kp701.fsf@cisco.com> <48F709C2.6000303@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: scofeldm@cisco.com, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:30730 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752197AbYJPWyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2008 18:54:17 -0400
In-Reply-To: <48F709C2.6000303@garzik.org> (Jeff Garzik's message of "Thu, 16
	Oct 2008 05:30:42 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > Sheesh, Cisco just does not have any sense of humor :)

Hey I thought name-checking Mark Everett in the changelog was kind of funny.

 > As I explained to Scott (in private email, unfortunately, IIRC), I did
 > that so that it would fit in the list alphabetized -- Scott placed it
 > in the section with the E's, not the C's.

Unfortunately Dave already applied my patch (and somehow dropped the
"From: Scott" part of my email so I get blamed ;).  I didn't realize the
list was alphabetized -- I guess we should add another patch to put this
in the right place in the list?

 > Furthermore, "Cisco 10G ethernet nic" is a vague description if Cisco
 > ever plans to sell another ethernet product.  Will the next one be
 > "Cisco 10G Ethernet NIC, the sequel"?  :)

I guess we're just counting on being on to 100G ethernet by the time we
do another NIC... but seriously we should probably figure out what the
marketing name will be and improve the help text.

 - R.
