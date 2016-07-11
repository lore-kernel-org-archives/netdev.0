From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 7/7] ARM: dts: NSP: Add bgmac entries
Date: Mon, 11 Jul 2016 09:50:30 -0700
Message-ID: <5783CE56.2040307@gmail.com>
References: <1467993362-13229-1-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: zajec5@gmail.com, hauke@hauke-m.de,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>, Ray Jui <rjui@broadcom.com>,
	Scott Branden <sbranden@broadcom.com>,
	bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Jon Mason <jon.mason@broadcom.com>, davem@davemloft.net,
	f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467993362-13229-1-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/08/2016 08:56 AM, Jon Mason wrote:
> Add device tree entries for the ethernet devices present on the
> Broadcom Northstar Plus SoCs
> 
> Signed-off-by: Jon Mason <jon.mason@broadcom.com>

Applied to devicetree/next, with s/bgmac/AMAC/ in the subject, thanks!
-- 
Florian
