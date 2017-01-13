From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 05/10] drivers: base: Add
 device_find_class()
Date: Thu, 12 Jan 2017 23:16:37 -0500 (EST)
Message-ID: <20170112.231637.1459914337755928344.davem@davemloft.net>
References: <20170112034121.27697-6-f.fainelli@gmail.com>
        <20170112.162135.441956368122992032.davem@davemloft.net>
        <81f5965c-3484-92d9-5c04-94c5b73735d0@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jason@lakedaemon.net, andrew@lunn.ch,
        sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com, linux@armlinux.org.uk,
        vivien.didelot@savoirfairelinux.com,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        gregkh@linuxfoundation.org
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <81f5965c-3484-92d9-5c04-94c5b73735d0@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 12 Jan 2017 14:50:39 -0800

> Well, this is really so that we don't need to cast the arguments passed
> to device_find_child(), which takes a void *data as well.

Aha, I didn't catch that, my bad.
