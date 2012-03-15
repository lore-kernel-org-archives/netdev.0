From: Kevin Wilson <wkevils@gmail.com>
Subject: net next git tree cloning - a problem
Date: Thu, 15 Mar 2012 21:51:41 +0200
Message-ID: <CAGXs5wVqqD=v3OruOPMewmUdEyMtGEV3RHwsNih+yBeFr5-fvQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:51752 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031828Ab2COTvm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Mar 2012 15:51:42 -0400
Received: by vcqp1 with SMTP id p1so3517756vcq.19
        for <netdev@vger.kernel.org>; Thu, 15 Mar 2012 12:51:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I want to clone net-next tree of davem.

AFAIK, this is the url to clone:
http://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git

Also according to next link, this is the url:
http://git.kernel.org/?p=linux/kernel/git/davem/net-next.git;a=summary


I tried today
git clone http://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git

and got a tree.
But
git log | more

shows:

commit cdf485be3a63d1f34293740fb726088c6840ceea
Author: John Fastabend <john.r.fastabend@intel.com>
Date:   Sat Feb 11 06:26:00 2012 +0000


I suppose there were patches since Feb 11 ...

Is there a different url for cloning net-next ?


rgs,
Kevin
