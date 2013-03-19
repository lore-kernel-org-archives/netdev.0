From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [BUG][mvebu] mvneta: cannot request irq 25 on openblocks-ax3
Date: Tue, 19 Mar 2013 20:48:41 +0100
Message-ID: <2482565.pAEcuMH9qj@bender>
References: <51486445.8040506@hitachi.com> <514873FB.5050202@hitachi.com> <514895C5.40706@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7Bit
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	thomas.petazzoni@free-electrons.com,
	Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"yrl.pp-manager.tt@hitachi.com" <yrl.pp-manager.tt@hitachi.com>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <514895C5.40706@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 19 March 2013 17:43:49 Gregory CLEMENT wrote:
> 
> Hi Masami,
> 
> You can try this patch if you want.
> I don't have the hardware today so I didn't test it.
> If you (and also Florian and Ezequiel) can test it and if it fixed
> the bug, then I will be able send a proper email for it,

I just tested your patch on RD-A370-A1 and DB-MV784MP-GP and it works fine, 
thanks! Feel free to add my Tested-by: Florian Fainelli <florian@openwrt.org> 
to your next submission.

Thanks!
-- 
Florian
