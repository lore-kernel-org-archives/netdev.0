From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: dsa: remove tag_protocol from dsa_switch
Date: Wed, 20 Apr 2016 10:59:27 -0700
Message-ID: <5717C37F.4060702@gmail.com>
References: <1461018244-5371-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461018244-5371-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 18/04/16 15:24, Vivien Didelot wrote:
> Having the tag protocol in dsa_switch_driver for setup time and in
> dsa_switch_tree for runtime is enough. Remove dsa_switch's one.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
