From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] ARM: gemini: remove unnecessary mdio-gpio
 includes
Date: Wed, 21 Oct 2015 19:50:55 -0700 (PDT)
Message-ID: <20151021.195055.697782375960817477.davem@davemloft.net>
References: <1445350139-2527-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, f.fainelli@gmail.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445350139-2527-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Tue, 20 Oct 2015 10:08:58 -0400

> Remove the inclusion of linux/mdio-gpio.h in nas4220b, wbd111 and wbd222
> boards since mdio-gpio is not used.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied.
