From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 89161] Regression in bonding driver with devices that have
 no MAC address
Date: Wed, 23 Sep 2015 11:00:44 -0700
Message-ID: <20150923110044.07bda5bb@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:36465 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784AbbIWSAd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 14:00:33 -0400
Received: by pacgz1 with SMTP id gz1so12583480pac.3
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 11:00:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 23 Sep 2015 04:07:34 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 89161] Regression in bonding driver with devices that have no MAC address


https://bugzilla.kernel.org/show_bug.cgi?id=89161

--- Comment #2 from Toby Corkindale <tjc@wintrmute.net> ---
Hi, just checking in to see if anyone's looked at this.. have seen there's been
a bunch of commits to the bonding driver since July 15 but the bit of relevant
code still looks the same.

-- 
You are receiving this mail because:
You are the assignee for the bug.
