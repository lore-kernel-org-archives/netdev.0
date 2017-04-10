From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH net-next v3 0/2] bpf: prog/map type reductions
Date: Mon, 10 Apr 2017 14:44:29 +0200
Message-ID: <20170410124431.4305-1-johannes@sipsolutions.net>
Cc: alexei.starovoitov@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:36920 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752343AbdDJMog (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Apr 2017 08:44:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here's a respin, with davem's suggestion incorporated.

bloat-o-meter output is long because I gave things some consistent
names, but the summary is:

add/remove: 19/61 grow/shrink: 4/3 up/down: 728/-1354 (-626)

johannes
