From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 52151] via_rhine stops making new tcp connections.
Date: Wed, 16 Jan 2013 13:45:27 -0800
Message-ID: <20130116134527.3f7fd8c1@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Roger Luethi <rl@hellgate.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f43.google.com ([209.85.210.43]:32847 "EHLO
	mail-da0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756720Ab3APVqz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 16:46:55 -0500
Received: by mail-da0-f43.google.com with SMTP id u36so763592dak.30
        for <netdev@vger.kernel.org>; Wed, 16 Jan 2013 13:46:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 16 Jan 2013 12:56:07 -0800
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 52151] via_rhine stops making new tcp connections.


https://bugzilla.kernel.org/show_bug.cgi?id=52151





--- Comment #4 from David W. Hodgins <davidwhodgins@gmail.com>  2013-01-16 20:55:59 ---
Created an attachment (id=91411)
 --> (https://bugzilla.kernel.org/attachment.cgi?id=91411)
dmesg output

Now that it's happened again, I've been able to get proper
dmesg output, but as shown, there are no error messages
being generated related to networking.

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.
