From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: [stable] Please apply ucc_geth patches to 2.6.32-stable
Date: Wed, 9 Jun 2010 11:02:55 +0300
Message-ID: <AANLkTin_EvlveCvbCZ0vH54UEP479ufQ-irFqXSOnT0R@mail.gmail.com>
References: <20100609071623.GC20057@colossus>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org, stable@kernel.org,
	avorontsov@ru.mvista.com,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Petri Lehtinen <petri.lehtinen@inoi.fi>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100609071623.GC20057@colossus>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 9, 2010 at 10:16 AM, Petri Lehtinen <petri.lehtinen@inoi.fi> wrote:
> The following three patches fix some serious flaws in the ucc_geth
> network driver in 2.6.32. From oldest to newest:
>
> 7583605b6d29f1f7f6fc505b883328089f3485ad ucc_geth: Fix empty TX queue processing
> 08b5e1c91ce95793c59a59529a362a1bcc81faae ucc_geth: Fix netdev watchdog triggering on link changes
> 34692421bc7d6145ef383b014860f4fde10b7505 ucc_geth: Fix full TX queue processing
>
> They apply cleanly on top of 2.6.32-stable master. They were also
> originally Cc'd to be included in 2.6.32-stable.

You forgot to CC stable@kernel.org, netdev, and the original author of
those patches.
