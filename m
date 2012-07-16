From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: [PATCH] net-next: make sock diag per-namespace
Date: Mon, 16 Jul 2012 19:26:45 +0200
Message-ID: <50044ED5.5070006@computer.org>
References: <1342440849-1757320-1-git-send-email-avagin@openvz.org> <1342441945.23494.23.camel@edumazet-glaptop> <20120716123815.GA1178@avaginn.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Vagin <avagin@openvz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Pavel Emelianov <xemul@parallels.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andrew Vagin <avagin@parallels.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120716123815.GA1178@avaginn.sw.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/16/2012 02:38 PM, Andrew Vagin wrote:
> You are right. Sorry for this stupid fault. I will send a new patch.

Before doing so:

Could you put the "net-next" inside the square brackets (being the tree you are aiming your patch at, which should not end up in the commit log), and mention the subsystem in its place? Perhaps simply "net"?

Just a suggestion.

Thanks, Jan
