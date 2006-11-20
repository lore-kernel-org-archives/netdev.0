From: James Bottomley <James.Bottomley@SteelEye.com>
Subject: Re: [RFC: 2.6 patch] remove the broken SKMC driver
Date: Mon, 20 Nov 2006 16:07:30 -0600
Message-ID: <1164060450.2816.103.camel@mulgrave.il.steeleye.com>
References: <20061120210648.GB31879@stusta.de>
	 <20061120140115.4cdec66a@freekitty>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@stusta.de>, jgarzik@pobox.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jejb@SteelEye.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S966846AbWKTWKd@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061120140115.4cdec66a@freekitty>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-11-20 at 14:01 -0800, Stephen Hemminger wrote:
> Are there any working microchannel drivers?

Yes: smc-mca for one.

>   Can we drop support for microchannel
> at the bus level?

No.

James
