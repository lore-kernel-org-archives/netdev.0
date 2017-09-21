From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/64] use setup_timer() helper function.
Date: Thu, 21 Sep 2017 11:39:27 -0700 (PDT)
Message-ID: <20170921.113927.1684139706973891956.davem@davemloft.net>
References: <1506013525-29291-1-git-send-email-allen.lkml@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        m.grzeschik@pengutronix.de, dmitry.tarnyagin@lockless.no,
        wg@grandegger.com, mkl@pengutronix.de, mark.einon@gmail.com,
        linux@armlinux.org.uk, pcnet32@frontier.com, f.fainelli@gmail.com,
        bcm-kernel-feedback-list@broadcom.com, venza@brownhat.org,
        ajk@comnets.uni-bremen.de, jes@trained-monkey.org,
        romieu@fr.zoreil.com, khc@pm.waw.pl, simon@thekelleys.org.uk,
        linux-can@vger.kernel.org,
        adi-buildroot-devel@lists.sourceforge.net
To: allen.lkml@gmail.com
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1506013525-29291-1-git-send-email-allen.lkml@gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allen Pais <allen.lkml@gmail.com>
Date: Thu, 21 Sep 2017 22:34:21 +0530

>  This series uses setup_timer() helper function. The series
> addresses the files under drivers/net/*.

I've reviewed this series and will apply it to net-next.

But please send out smaller chunks next time, maybe 10-15
in a bunch?  64 patches at once makes it really hard for
reviewiers.

Thanks.
