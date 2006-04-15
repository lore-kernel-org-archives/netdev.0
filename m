From: Faidon Liambotis <faidon@cube.gr>
Subject: Re: [RFC] Geographical/regulatory information for ieee80211
Date: Sat, 15 Apr 2006 20:07:30 +0300
Message-ID: <e1r98k$882$1@sea.gmane.org>
References: <443EF3E9.7050303@lwfinger.net> <20060414152715.GC29461@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:42458 "EHLO ciao.gmane.org")
	by vger.kernel.org with ESMTP id S1030295AbWDORHx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Apr 2006 13:07:53 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1FUoFN-0005G2-2v
	for netdev@vger.kernel.org; Sat, 15 Apr 2006 19:07:46 +0200
Received: from 147.102.26.135 ([147.102.26.135])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 15 Apr 2006 19:07:45 +0200
Received: from faidon by 147.102.26.135 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 15 Apr 2006 19:07:45 +0200
To: netdev@vger.kernel.org
In-Reply-To: <20060414152715.GC29461@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jouni Malinen wrote:
> The maximum power would be quite useful--I would say required--part of
> regulatory domain information.. In other words, I would like to see the
> groups created in a way that would take differences in power limits into
> account. Without this, the groups will need to be re-created at some
> point in the future when IEEE 802.11d and IEEE 802.11h would like to use
> the same table.. In addition, flag of specifying indoor/outdoor/both
> would be a nice addition.
Speaking of 802.11h, for the table to be complete, it should specify
which protocol is allowed on a given channel.
EU members allow 802.11h (DFS/TPC) but not 802.11a. This is an important
distinction that, IMHO, should be included in a regulatory information
table.

Regards,
Faidon

