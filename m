From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 4/5] net-next: ethernet: mediatek: add
 device_node of GMAC pointing into the netdev instance
Date: Wed, 22 Mar 2017 11:23:03 -0700
Message-ID: <7a6d4273-bdac-42f5-9f50-a43bdd952495@gmail.com>
References: <1490088910-19405-1-git-send-email-sean.wang@mediatek.com>
 <1490088910-19405-5-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org,
        davem@davemloft.net, Landen.Chao@mediatek.com, keyhaede@gmail.com,
        objelf@gmail.com
To: sean.wang@mediatek.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, matthias.bgg@gmail.com,
        robh+dt@kernel.org, mark.rutland@arm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:34529 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965542AbdCVSXL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 14:23:11 -0400
In-Reply-To: <1490088910-19405-5-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/21/2017 02:35 AM, sean.wang@mediatek.com wrote:
> From: Sean Wang <sean.wang@mediatek.com>
> 
> the patch adds the setup of the corresponding device node of GMAC into the
> netdev instance which could allow other modules such as DSA to find the
> instance through the node in dt-bindings using of_find_net_device_by_node()
> call.
> 
> Signed-off-by: Sean Wang <sean.wang@mediatek.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
