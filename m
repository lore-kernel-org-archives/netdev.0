From: Sjur BRENDELAND <sjur.brandeland@stericsson.com>
Subject: RE: linux-next: manual merge of the net-next tree with the net tree
Date: Fri, 29 Jun 2012 08:46:04 +0200
Message-ID: <81C3A93C17462B4BBD7E272753C10579232F86B36C@EXDCVYMBSTM005.EQ1STM.local>
References: <20120626131543.21e4338894b19f5e02f8bdde@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Per ELLEFSEN <per.ellefsen@stericsson.com>,
	Kim LILLIESTIERNA <kim.xx.lilliestierna@stericsson.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20120626131543.21e4338894b19f5e02f8bdde@canb.auug.org.au>
Content-Language: en-US
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

> Today's linux-next merge of the net-next tree got a conflict in
> drivers/net/caif/caif_hsi.c between commits 3935600a7f34 ("caif-hsi:
> Bugfix - Piggyback'ed embedded CAIF frame lost") and 1fdc7630b2cb
> ("caif-hsi: Add missing return in error path") from the net tree and
> commits 4e7bb59d49fb ("caif-hsi: Removed dead code") and c41254006377
> ("caif-hsi: Add rtnl support") from the net-next tree.
> 
> I fixed them up (see below) and can carry the fix as necessary.

Sorry for late response. Your merge looks perfect.

Thanks,
Sjur
