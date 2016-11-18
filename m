From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH net-next] cadence: Add hardware PTP support.
Date: Fri, 18 Nov 2016 12:12:21 +0100
Message-ID: <c96d149b-3448-b922-39c2-68b07e0f453a@atmel.com>
References: <1479466028-29914-1-git-send-email-rafalo@cadence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: Harini Katakam <harinikatakamlinux@gmail.com>,
        <linux-kernel@vger.kernel.org>
To: Rafal Ozieblo <rafalo@cadence.com>,
        Andrei Pistirica <Andrei.Pistirica@microchip.com>,
        <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479466028-29914-1-git-send-email-rafalo@cadence.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 18/11/2016 à 11:47, Rafal Ozieblo a écrit :
> Signed-off-by: Rafal Ozieblo <rafalo@cadence.com>

Note to David: This is more a RFC: we are discussing the addition of
this feature and how to cover all macb revisions and optional features
implemented in actual products.

regards,

> ---
>  Documentation/devicetree/bindings/net/macb.txt |   1 +
>  drivers/net/ethernet/cadence/macb.c            | 742 ++++++++++++++++++++++++-
>  drivers/net/ethernet/cadence/macb.h            | 217 +++++++-
>  3 files changed, 950 insertions(+), 10 deletions(-)

[..]

-- 
Nicolas Ferre
