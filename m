From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: remove tag_protocol from dsa_switch
Date: Thu, 21 Apr 2016 13:44:00 -0400 (EDT)
Message-ID: <20160421.134400.2124455560669100364.davem@davemloft.net>
References: <1461018244-5371-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461018244-5371-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Mon, 18 Apr 2016 18:24:04 -0400

> Having the tag protocol in dsa_switch_driver for setup time and in
> dsa_switch_tree for runtime is enough. Remove dsa_switch's one.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied.
