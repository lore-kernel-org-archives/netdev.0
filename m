From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: Synopsys Ethernet QoS
Date: Sat, 10 Dec 2016 00:25:15 +0200
Message-ID: <CAHp75VcKURaTQX9=SY8+46GGATuwO1oXAi8eMS+uwk58sjKx5Q@mail.gmail.com>
References: <2df7a6dd-1128-d1d6-bf61-891f76cf7200@synopsys.com>
 <20161209.103327.1742213347114742435.davem@davemloft.net> <93b73b79-36aa-56b8-f975-b890b7a48bd1@synopsys.com>
 <20161209.104152.1969880574279771010.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Joao Pinto <Joao.Pinto@synopsys.com>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        lars.persson@axis.com, rabin.vincent@axis.com,
        netdev <netdev@vger.kernel.org>, CARLOS.PALMINHA@synopsys.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:34316 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753341AbcLIWZQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 17:25:16 -0500
Received: by mail-oi0-f65.google.com with SMTP id m75so4095366oig.1
        for <netdev@vger.kernel.org>; Fri, 09 Dec 2016 14:25:16 -0800 (PST)
In-Reply-To: <20161209.104152.1969880574279771010.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 9, 2016 at 5:41 PM, David Miller <davem@davemloft.net> wrote:

> But one thing I am against is changing the driver name for existing
> users.  If an existing chip is supported by the stmmac driver for
> existing users, they should still continue to use the "stmmac" driver.
>
> Therefore, if consolidation changes the driver module name for
> existing users, then that is not a good plan at all.

You have at least one supporter here. Though I jumped in to the
discussion very late, not sure if everyone have time to answer to
that.

-- 
With Best Regards,
Andy Shevchenko
