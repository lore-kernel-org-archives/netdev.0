From: Andi Kleen <ak@muc.de>
Subject: Re: netif_rx packet dumping
Date: 10 Mar 2005 09:33:09 +0100
Message-ID: <20050310083309.GA510@muc.de>
References: <20050303123811.4d934249@dxpl.pdx.osdl.net> <42278122.6000000@ev-en.org> <20050303133659.0d224e61.davem@davemloft.net> <42278554.2090902@ev-en.org> <20050303135718.2e1a0170.davem@davemloft.net> <422DC7CE.2040800@ev-en.org> <m1y8cykr7i.fsf@muc.de> <20050308100902.24b67b2f.davem@davemloft.net> <422DEE85.5010302@candelatech.com> <20050309235728.GV31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>,
        "David S. Miller" <davem@davemloft.net>, baruch@ev-en.org,
        shemminger@osdl.org, netdev@oss.sgi.com
Date: Thu, 10 Mar 2005 09:33:09 +0100
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20050309235728.GV31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> I attached a small patch below saving 4 bytes and leaving some room for
> additional flags. The removal of security has indeed potential to break
> external modules.

And? The Linux kernel never had a stable ABI.

-Andi
