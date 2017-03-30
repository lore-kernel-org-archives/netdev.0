From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND net-next] net: dsa: mv88e6xxx: debug ATU Age Time
Date: Thu, 30 Mar 2017 15:35:49 -0700 (PDT)
Message-ID: <20170330.153549.1859766806259882520.davem@davemloft.net>
References: <20170329193837.28882-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch,
        jcobham@questertangent.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170329193837.28882-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Wed, 29 Mar 2017 15:38:37 -0400

> The ATU ageing time value programmed in the switch is rounded up to the
> nearest multiple of its coefficient (variable depending on the model.)
> 
> Add a debug message to inform the user about the exact programmed value.
> 
> On 6352, "brctl setageing br0 18" gives "AgeTime set to 0x01 (15000 ms)"
> while on 6390 we get "AgeTime set to 0x05 (18750 ms)".
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied.
