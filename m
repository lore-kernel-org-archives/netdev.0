From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/7] net: dsa: add port parse functions
Date: Mon, 30 Oct 2017 11:37:49 -0700
Message-ID: <8d750feb-53e1-b148-764f-05e64784d048@gmail.com>
References: <20171027195519.5931-1-vivien.didelot@savoirfairelinux.com>
 <20171027195519.5931-3-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171027195519.5931-3-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/27/2017 12:55 PM, Vivien Didelot wrote:
> Add symmetrical DSA port parsing functions for pdata and device tree,
> used to parse and validate a given port node or platform data.
> 
> They don't do much for the moment but will be extended later on to
> assign a port type and get device references.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
