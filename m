From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/2] lan9303: Add basic offloading of
 unicast traffic
Date: Wed, 11 Oct 2017 13:53:36 -0700 (PDT)
Message-ID: <20171011.135336.322141911095287928.davem@davemloft.net>
References: <20171010124953.386-1-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: privat@egil-hjelmeland.no
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171010124953.386-1-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Date: Tue, 10 Oct 2017 14:49:51 +0200

> This series add basic offloading of unicast traffic to the lan9303
> DSA driver.
> 
> Review welcome!
>  
> Changes v1 -> v2:
>  - Patch 1: Codestyle linting.
>  - Patch 2: Remember SWE_PORT_STATE while not bridged.
>             Added constant LAN9303_SWE_PORT_MIRROR_DISABLED.

Series applied, thanks.
