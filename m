From: Ben Greear <greearb@candelatech.com>
Subject: Can libpcap filter on vlan tags when vlans are hardware-accelerated?
Date: Tue, 12 Sep 2017 11:54:43 -0700
Message-ID: <51a124d5-8a5f-35d4-5242-fd8a289f50b5@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:34188 "EHLO
        mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750944AbdILSyn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2017 14:54:43 -0400
Received: from [192.168.100.149] (firewall.candelatech.com [50.251.239.81])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail2.candelatech.com (Postfix) with ESMTPSA id 66B8940A5CB
        for <netdev@vger.kernel.org>; Tue, 12 Sep 2017 11:54:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It does not appear to work on Fedora-26, and I'm curious if someone knows what needs
doing to get this support working?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
