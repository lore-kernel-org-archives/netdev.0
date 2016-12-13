From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v2 1/2] net: rfkill: Cleanup error handling in
 rfkill_init()
Date: Tue, 13 Dec 2016 16:16:20 +0100
Message-ID: <1481642180.20412.1.camel@sipsolutions.net>
References: <20161208073052.12988-1-kernel@kempniu.pl>
         (sfid-20161208_083101_604229_2D2C8421)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: =?UTF-8?Q?Micha=C5=82_K=C4=99pie=C5=84?= <kernel@kempniu.pl>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161208073052.12988-1-kernel@kempniu.pl> (sfid-20161208_083101_604229_2D2C8421)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-12-08 at 08:30 +0100, Michał Kępień wrote:
> Use a separate label per error condition in rfkill_init() to make it
> a bit cleaner and easier to extend.

applied.

johannes
