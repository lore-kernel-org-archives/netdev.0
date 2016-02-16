From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ti: netcp: restore get/set_pad_info()
 functionality
Date: Tue, 16 Feb 2016 15:24:21 -0500 (EST)
Message-ID: <20160216.152421.2271194730635382792.davem@davemloft.net>
References: <1455026303-17014-1-git-send-email-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arnd@arndb.de, fcooper@ti.com,
	nsekhar@ti.com, linux-kernel@vger.kernel.org, w-kwok2@ti.com,
	m-karicheri2@ti.com, mugunthanvnm@ti.com
To: grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455026303-17014-1-git-send-email-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I would like some of the feedback to be taken into consideration and
integrated into this patch.

Part of the reason this regression was introduced was probably because
the purpose of some fields or descriptor semantics was not defined
properly.

Therefore it is absolutely appropriate to properly name and document
these fields as part of the bug fix.

Thank you.
