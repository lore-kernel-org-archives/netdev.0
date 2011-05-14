From: Reuben Hawkins <reubenhwk@gmail.com>
Subject: radvd v1.8 released
Date: Sat, 14 May 2011 07:50:05 -0700
Message-ID: <BANLkTi=b_Gsk-iBRZtDpJ9TGifZFj1R1+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: radvd-announce-l@litech.org,
	radvd Development Discussion <radvd-devel-l@litech.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:43271 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758045Ab1ENOuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2011 10:50:06 -0400
Received: by fxm17 with SMTP id 17so2275195fxm.19
        for <netdev@vger.kernel.org>; Sat, 14 May 2011 07:50:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

Radvd v1.8 was just released.  The release highlights are...

*    IgnoreIfMissing now defaults to on
*    Timer code replaced with poll
*    radvd now listens for interface state changes on a netlink socket
*    DecrementLifetimes
*    DeprecatePrefix
*    FlushRoute
*    BugFix in DNSSL parsing

Radvd v1.8 can be downloaded at http://www.litech.org/radvd.  Please
report any bugs or problems to radvd-devel-l@litech.org.

Thanks,
Reuben
