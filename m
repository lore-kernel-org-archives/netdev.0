From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v3 5/5] net-next: dsa: add dsa support for
 Mediatek MT7530 switch
Date: Wed, 24 May 2017 15:20:49 +0200
Message-ID: <20170524132049.GB24980@lunn.ch>
References: <1490780303-18598-1-git-send-email-sean.wang@mediatek.com>
 <1490780303-18598-6-git-send-email-sean.wang@mediatek.com>
 <hn6gvd-qp1.ln1@banana.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org
To: "Andrey Jr. Melnikov" <temnota.am@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <hn6gvd-qp1.ln1@banana.localnet>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> What about JUMBO frames and large MTU support? devlink support?

To get the driver merged, it is better to start small, a minimal set
of features. Other features can be added later. If these features are
important to you, please feel free to submit patches.

	  Andrew
