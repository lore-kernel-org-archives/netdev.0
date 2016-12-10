From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: Synopsys Ethernet QoS
Date: Sat, 10 Dec 2016 02:16:53 +0200
Message-ID: <CAHp75VfT9B3O5jU0eHoKtgYc48K2ZjCQ-g9ZQ9nX1Hew6tz-zw@mail.gmail.com>
References: <2df7a6dd-1128-d1d6-bf61-891f76cf7200@synopsys.com>
 <20161209.103327.1742213347114742435.davem@davemloft.net> <93b73b79-36aa-56b8-f975-b890b7a48bd1@synopsys.com>
 <20161209.104152.1969880574279771010.davem@davemloft.net> <CAHp75VcKURaTQX9=SY8+46GGATuwO1oXAi8eMS+uwk58sjKx5Q@mail.gmail.com>
 <3aee5a67-5e19-34e6-1719-ff13c7b914ea@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        lars.persson@axis.com, rabin.vincent@axis.com,
        netdev <netdev@vger.kernel.org>, CARLOS.PALMINHA@synopsys.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:34534 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751726AbcLJAQy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 19:16:54 -0500
Received: by mail-oi0-f65.google.com with SMTP id m75so4333983oig.1
        for <netdev@vger.kernel.org>; Fri, 09 Dec 2016 16:16:54 -0800 (PST)
In-Reply-To: <3aee5a67-5e19-34e6-1719-ff13c7b914ea@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 10, 2016 at 12:52 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:

> It's kind of sad that customers of that IP (stmmac, amd-xgbe, sxgbe)

> did
> actually pioneer the upstreaming effort, but it is good to see people
> from Synopsys willing to fix that in the future.

Wait, you would like to tell that we have more than 2 drivers for the
same (okay, same vendor) IP?!
It's better to unify them earlier, than have n+ copies.

P.S. Though, I don't see how sxgbe got in the list. First glance on
the code doesn't show similarities.

-- 
With Best Regards,
Andy Shevchenko
