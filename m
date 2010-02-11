From: Bernard Pidoux <bpidoux@free.fr>
Subject: [PATCH 07/13] net: ax25: use seq_hlist_foo() helpers
Date: Thu, 11 Feb 2010 17:34:48 +0100
Message-ID: <4B7431A8.9010902@free.fr>
References: <4B2E6729.1090102@free.fr>	<4B507FAA.8010007@free.fr>	<20100115203654.GA3084@del.dom.local> <20100116.010435.55169828.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100116.010435.55169828.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Li Zefan,

Your patches 1, 2, 3, 4, 6, 7, 9, 10/13 applied.
kernel and modules compiled ok.
AX25 and ROSE are working fine.

Thanks.

Bernard


Simplify seq_file code.

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 net/ax25/af_ax25.c  |   18 +++---------------
 net/ax25/ax25_uid.c |   25 ++++---------------------
 2 files changed, 7 insertions(+), 36 deletions(-)
