From: "Kondratiev, Vladimir" <vkondrat@qti.qualcomm.com>
Subject: RE: randconfig build error with next-20140604, in
 drivers/net/wireless/ath/wil6210/debugfs.c
Date: Fri, 20 Jun 2014 16:43:38 +0000
Message-ID: <A5CA08B46412E243958C77F3825F4395270AB72A@NASANEXD02E.na.qualcomm.com>
References: <CA+r1ZhiT6hHwA2urc-DXUxucvJYaYdq-dZZSAFrgd3du_DDrww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Jim Davis <jim.epost@gmail.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next <linux-next@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	qca_vkondrat <qca_vkondrat@qca.qualcomm.com>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	wil6210 <wil6210@qca.qualcomm.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <CA+r1ZhiT6hHwA2urc-DXUxucvJYaYdq-dZZSAFrgd3du_DDrww@mail.gmail.com>
Content-Language: en-US
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Building with the attached random configuration file,

drivers/built-in.o: In function `wil_vring_debugfs_show':
debugfs.c:(.text+0x3a331c): undefined reference to `__udivdi3'
make: *** [vmlinux] Error 1

Patch already sent.

Thanks, Vladimir