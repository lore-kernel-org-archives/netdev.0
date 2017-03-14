From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 05/12] net: bcmgenet: manage dma interrupts in
 napi code
Date: Mon, 13 Mar 2017 17:55:59 -0700
Message-ID: <aeafc712-dcc4-3022-56d5-29bc111d112a@gmail.com>
References: <20170314004142.4746-1-opendmb@gmail.com>
 <20170314004142.4746-6-opendmb@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, mark.rutland@arm.com, davem@davemloft.net,
        rafal@milecki.pl, xow@google.com, joel@jms.id.au,
        jon.mason@broadcom.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        pgynther@google.com, jaedon.shin@gmail.com
To: Doug Berger <opendmb@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170314004142.4746-6-opendmb@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/13/2017 05:41 PM, Doug Berger wrote:
> This commit moves DMA interrupt enabling out of init_umac() and adds
> the masking of these interrupts to the napi enable and disable code.
> 
> Signed-off-by: Doug Berger <opendmb@gmail.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
