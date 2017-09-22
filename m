From: Allen <allen.lkml@gmail.com>
Subject: Re: [PATCH 00/64] use setup_timer() helper function.
Date: Fri, 22 Sep 2017 11:52:28 +0530
Message-ID: <CAOMdWSLwH0iCp3fLH=L0f-pRkBhpCXOnf43W=P7n2LqYFiU7sg@mail.gmail.com>
References: <1506013525-29291-1-git-send-email-allen.lkml@gmail.com> <20170921.113927.1684139706973891956.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        m.grzeschik@pengutronix.de, dmitry.tarnyagin@lockless.no,
        wg@grandegger.com, mkl@pengutronix.de,
        Mark Einon <mark.einon@gmail.com>, linux@armlinux.org.uk,
        pcnet32@frontier.com, Florian Fainelli <f.fainelli@gmail.com>,
        bcm-kernel-feedback-list@broadcom.com, venza@brownhat.org,
        ajk@comnets.uni-bremen.de, jes@trained-monkey.org,
        romieu@fr.zoreil.com, khc@pm.waw.pl,
        Simon Kelley <simon@thekelleys.org.uk>,
        linux-can@vger.kernel.org,
        adi-buildroot-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170921.113927.1684139706973891956.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>
>>  This series uses setup_timer() helper function. The series
>> addresses the files under drivers/net/*.
>
> I've reviewed this series and will apply it to net-next.
>
> But please send out smaller chunks next time, maybe 10-15
> in a bunch?  64 patches at once makes it really hard for
> reviewiers.

 My apologies. I'll make sure I break it into smaller chunks
in the future.


-- 
       - Allen
