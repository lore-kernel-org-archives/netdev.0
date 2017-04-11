From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next v3 2/2] bpf: remove struct bpf_map_type_list
Date: Tue, 11 Apr 2017 15:29:18 +0200
Message-ID: <1491917358.31620.28.camel@sipsolutions.net>
References: <20170410124431.4305-1-johannes@sipsolutions.net>
         <20170410124431.4305-3-johannes@sipsolutions.net>
         (sfid-20170410_144515_702266_3C441074)
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:50620 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752052AbdDKN3V (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 09:29:21 -0400
In-Reply-To: <20170410124431.4305-3-johannes@sipsolutions.net> (sfid-20170410_144515_702266_3C441074)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

0-day found a linking problem with this, I'll resubmit later.

johannes
