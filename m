From: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Subject: Re: Re: [BUG][mvebu] mvneta: cannot request irq 25 on openblocks-ax3
Date: Thu, 21 Mar 2013 10:56:22 +0900
Message-ID: <514A68C6.707@hitachi.com>
References: <51486445.8040506@hitachi.com> <20130319133928.GE3137@localhost> <514873FB.5050202@hitachi.com> <514895C5.40706@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	thomas.petazzoni@free-electrons.com,
	Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"yrl.pp-manager.tt@hitachi.com" <yrl.pp-manager.tt@hitachi.com>,
	Florian Fainelli <florian@openwrt.org>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <514895C5.40706@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(2013/03/20 1:43), Gregory CLEMENT wrote:
> Hi Masami,
> 
> You can try this patch if you want.
> I don't have the hardware today so I didn't test it.
> If you (and also Florian and Ezequiel) can test it and if it fixed
> the bug, then I will be able send a proper email for it,

Hi Gregory,

Thank you for giving me the latest patch.
I've tested it on OpenBlocks-AX4 and that fixed the problem!

Tested-by: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>

Thanks,
-- 
Masami HIRAMATSU
IT Management Research Dept. Linux Technology Center
Hitachi, Ltd., Yokohama Research Laboratory
E-mail: masami.hiramatsu.pt@hitachi.com
