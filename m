From: Kevin Wilson <wkevils@gmail.com>
Subject: pulling net-netx git tree
Date: Fri, 9 Dec 2011 19:42:19 +0200
Message-ID: <CAGXs5wXc-dFs8uJXUpNpYUMs_rSwXV_r4zfWPSzkLPf0qxV-rw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:35572 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752316Ab1LIRmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2011 12:42:19 -0500
Received: by vbbfc26 with SMTP id fc26so2490580vbb.19
        for <netdev@vger.kernel.org>; Fri, 09 Dec 2011 09:42:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
  I am trying to update my net-next tree, and I get
git pull

Already up-to-date.

git log
shows:

commit 88c5100c28b02c4b2b2c6f6fafbbd76d90f698b9
Merge: 8083f0f 3ee72ca
Author: David S. Miller <davem@davemloft.net>
Date:   Fri Oct 7 13:38:43 2011 -0400

    Merge branch 'master' of github.com:davem330/net

...
...

commit 8083f0fc969d9b5353061a7a6f963405057e26b1
Author: Johannes Berg <johannes.berg@intel.com>
Date:   Fri Oct 7 03:30:20 2011 +0000

...
...


more .git/config
shows
url = https://github.com/davem330/net-next.git


should I change this url ?  and if so - to what ?


rgs,
Kevin
