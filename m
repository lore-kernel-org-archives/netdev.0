From: "Andy Johnson" <johnsonzjo@gmail.com>
Subject: Cannot git-clone the 2.6.26 tree
Date: Sun, 2 Mar 2008 17:30:48 +0200
Message-ID: <147a89290803020730r3865946esd4c6808c6b35ce79@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:20540 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751848AbYCBPav (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2008 10:30:51 -0500
Received: by fg-out-1718.google.com with SMTP id e21so4659513fga.17
        for <netdev@vger.kernel.org>; Sun, 02 Mar 2008 07:30:50 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Following this recent post in netdev, I tried getting 2.6.26 git tree :
( http://www.spinics.net/lists/netdev/msg56517.htmlt)

I tried several times today:

git-clone git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git
2.6.26 2.6.26

And got:
Initialized empty Git repository in /work/src/netGit2.6.26/2.6.26/.git/
fatal: The remote end hung up unexpectedly
fetch-pack from
'git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git'
failed.


Am I missing somethig?
cheers,

AJ
