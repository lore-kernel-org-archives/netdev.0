From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 6/6] net: dsa: remove port_fdb_getnext
Date: Wed, 14 Oct 2015 11:50:19 -0700
Message-ID: <561EA3EB.5080804@gmail.com>
References: <1444754783-26975-1-git-send-email-vivien.didelot@savoirfairelinux.com> <1444754783-26975-7-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>, Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444754783-26975-7-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13/10/15 09:46, Vivien Didelot wrote:
> No driver implements port_fdb_getnext anymore, and port_fdb_dump is
> preferred anyway, so remove this function from DSA.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
