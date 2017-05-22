From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 18/20] net: dsa: add FDB notifier
Date: Mon, 22 May 2017 12:39:09 -0700
Message-ID: <7555183f-f071-4d73-e8f0-57fd06c22c48@gmail.com>
References: <20170519210055.9366-1-vivien.didelot@savoirfairelinux.com>
 <20170519210055.9366-19-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170519210055.9366-19-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/19/2017 02:00 PM, Vivien Didelot wrote:
> Add two new DSA_NOTIFIER_FDB_ADD and DSA_NOTIFIER_FDB_DEL events to
> notify not only a single switch, but all switches of a the fabric when
> an FDB entry is added or removed.
> 
> For the moment, keep the current behavior and ignore other switches.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
