From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH] bnx2x: use ktime_get_seconds() for timestamp
Date: Fri, 11 Sep 2015 10:29:33 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63E2532D@avmb3.qlogic.org>
References: <2387233.xmDni0GXyg@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "y2038@lists.linaro.org" <y2038@lists.linaro.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>, netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2387233.xmDni0GXyg@wuerfel>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I assume that it is not possible to change the ABI any more, otherwise
> we should try to use a 64-bit field.

Actually, I did suggest exactly that to our management team,
But this was the decided ABI. 

Acked-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
