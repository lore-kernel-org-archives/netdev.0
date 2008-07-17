From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Subject: Re: [PATCH net-next] atl1e: Atheros L1E Gigabit Ethernet driver
Date: Thu, 17 Jul 2008 22:04:14 +0200
Message-ID: <200807172204.15342.m.kozlowski@tuxland.pl>
References: <12162854952457-git-send-email-jie.yang@atheros.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, yjwei@cn.fujitsu.com, rdreier@cisco.com,
	shemminger@vyatta.com, davem@davemloft.net, jcliburn@gmail.com,
	parag.warudkar@gmail.com, w@1wt.eu,
	oliver.schuster@schweigstill.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jie.yang@atheros.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932726AbYGQUEg@vger.kernel.org>
In-Reply-To: <12162854952457-git-send-email-jie.yang@atheros.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

> +#define SPEED_0		   0xffff
> +#define SPEED_10           10
> +#define SPEED_100          100
> +#define SPEED_100          100

Small thing - double define for SPEED_100.

> +#define SPEED_1000         1000

	Mariusz
