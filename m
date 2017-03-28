From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] ARM: dts: vf610-zii-dev-rev-b: change switch2
 label
Date: Tue, 28 Mar 2017 12:14:43 -0700
Message-ID: <b4cfecb4-af1c-1ead-b12f-14c20af0f3ac@gmail.com>
References: <20170328191126.18773-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170328191126.18773-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/28/2017 12:11 PM, Vivien Didelot wrote:
> Rename the switch2@0 label of the switch2 node to switch@0 to respect
> the general unit@address DTS rule, and be consistent with the other
> switch nodes of the DTS file.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

This looks good, but you certainly want the ARM SoC maintainer for that
platform to be able to pick that change through his tree, can you
resubmit with the proper CC list?

Thanks!
-- 
Florian
