From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] net: dsa: mv88e6352: add support for port_vlan_dump
Date: Wed, 24 Jun 2015 02:22:00 -0700 (PDT)
Message-ID: <20150624.022200.1877987180197149014.davem@davemloft.net>
References: <1435095970-18576-1-git-send-email-vivien.didelot@savoirfairelinux.com>
	<1435095970-18576-4-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch, f.fainelli@gmail.com,
	linux@roeck-us.net, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1435095970-18576-4-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Tue, 23 Jun 2015 17:46:10 -0400

> Add support for dumping the VLAN Table Unit entries by pointing to the
> port_vlan_dump function implemented for mv88e6xxx.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

There is no reason to separate this from patch #2.
