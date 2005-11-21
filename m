From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: [2.6 patch] kill drivers/net/irda/sir_core.c
Date: Mon, 21 Nov 2005 10:09:05 -0800
Message-ID: <20051121180905.GB26046@bougret.hpl.hp.com>
References: <20051120232904.GM16060@stusta.de>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932437AbVKUSJi@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20051120232904.GM16060@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 21, 2005 at 12:29:04AM +0100, Adrian Bunk wrote:
> EXPORT_SYMBOL's do nowadays belong to the files where the actual 
> functions are.
> 
> Moving the module_init/module_exit to the file with the actual functions 
> has the advantage of saving a few bytes due to the removal of two 
> functions.
> 
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

	Go for it.
	Ack-by : Jean Tourrilhes <jt@hpl.hp.com>

	Jean
