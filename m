From: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Subject: latest netdev net-next kernel panic
Date: Thu, 7 Sep 2017 23:30:43 +0200
Message-ID: <9f4c89c9-1a1b-39ec-6d8c-2c9e4c15911a@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp16.iq.pl ([86.111.242.222]:48977 "EHLO smtp16.iq.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932373AbdIGVcu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 7 Sep 2017 17:32:50 -0400
Received: from [192.168.2.200] (unknown [185.78.72.19])
        (Authenticated sender: pstaszewski@itcare.pl)
        by smtp.iq.pl (Postfix) with ESMTPSA id 3xpDFX5D5pz3xFW
        for <netdev@vger.kernel.org>; Thu,  7 Sep 2017 23:32:48 +0200 (CEST)
Content-Language: pl
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I want to mention also here cause last trace for RIP was dst_dev_put

https://bugzilla.kernel.org/attachment.cgi?id=258259
