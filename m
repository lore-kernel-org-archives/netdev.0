From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [patch -next] r8169: fix an if condition
Date: Mon, 22 Sep 2014 02:30:36 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2525102@RTITMBSV03.realtek.com.tw>
References: <20140919104025.GA26391@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>,
	nic_swsd <nic_swsd@realtek.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20140919104025.GA26391@mwanda>
Content-Language: zh-TW
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 From: Dan Carpenter [mailto:dan.carpenter@oracle.com] 
> Sent: Friday, September 19, 2014 6:40 PM
[...]
> There is an extra semi-colon so __rtl8169_set_features() is 
> called every
> time.

Acked-by: Hayes Wang <hayeswang@realtek.com>