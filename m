From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] net/rose/: misc possible cleanups
Date: Mon, 27 Dec 2004 21:16:46 -0800
Message-ID: <20041227211646.58326434.davem@davemloft.net>
References: <20041215012347.GF12937@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, linux-hams@vger.kernel.org,
	netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20041215012347.GF12937@stusta.de>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 15 Dec 2004 02:23:47 +0100
Adrian Bunk <bunk@stusta.de> wrote:

> The patch below contains the following possible cleanups:
> - make some needlessly global code static
> - remove the followingunused global functions:
>   - rose_dev.c: rose_rx_ip
>   - rose_link.c: rose_transmit_diagnostic

Applied, thanks Adrian.
