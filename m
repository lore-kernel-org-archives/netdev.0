From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: Extend irq_set_affinity_notifier() to use a call chain
Date: Mon, 26 May 2014 13:15:43 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1405261313570.21720@ionos.tec.linutronix.de>
References: <5381DEDC.8050204@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ben Hutchings <ben@decadent.org.uk>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>, idos@mellanox.com,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: amirv@mellanox.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5381DEDC.8050204@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 25 May 2014, Amir Vadai wrote:
> In order to do that, I need to add a new irq affinity notification
> callback (In addition to the existing cpu_rmap notification). For
> that I would like to extend irq_set_affinity_notifier() to have a
> notifier call-chain instead of a single notifier callback.

Why? "I would like" is a non argument.

Thanks,

	tglx
