From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH 1/1] qed: do not use unitialized variable
Date: Sun, 31 Jul 2016 11:34:15 +0000
Message-ID: <CO2PR11MB00886F3CBB50C3D2768EF8D197030@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1469964292-3231-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: Heinrich Schuchardt <xypron.glpk@gmx.de>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1469964292-3231-1-git-send-email-xypron.glpk@gmx.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Do not write random bytes from the kernel stack when calling qed_wr.
> 
> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>

Thanks.

Acked-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
