From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] staging: rtlwifi: Improve debugging by using debugfs
Date: Fri, 25 Aug 2017 08:47:00 -0500
Message-ID: <1a1ca849-3aec-60e3-b5a3-98a6e095d298@lwfinger.net>
References: <20170824212808.26632-1-Larry.Finger@lwfinger.net>
 <20170825015421.GA8852@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, netdev@vger.kernel.org,
        devel@driverdev.osuosl.org, Ping-Ke Shih <pkshih@realtek.com>,
        Yan-Hsuan Chuang <yhchuang@realtek.com>,
        Birming Chiu <birming@realtek.com>,
        Shaofu <shaofu@realtek.com>, Steven Ting <steventing@realtek.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:37173 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754375AbdHYNrC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 09:47:02 -0400
Received: by mail-oi0-f67.google.com with SMTP id b184so2124894oih.4
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 06:47:02 -0700 (PDT)
In-Reply-To: <20170825015421.GA8852@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/24/2017 08:54 PM, Andrew Lunn wrote:
> netdev frowns upon debugfs. You should try to keep this altogether,
> making it easy to throw away before the driver is moved out of
> staging.
> 
> You might want to look at ethtool -d. That will be accepted.

Andrew,

What is the problem with debugfs?

Please suggest which driver has the best example of an ethtool -d implementation 
that we might study.

The first version of the debugfs changes were sent to wireless-drivers on July 
2. Why are we first hearing of this objection nearly 2 months later?

Larry
