From: Andi Kleen <ak@suse.de>
Subject: Re: [2.6 patch] drivers/net/{,wireless/}Kconfig: remove dead URL
Date: Wed, 11 Jan 2006 01:53:21 +0100
Message-ID: <200601110153.21989.ak@suse.de>
References: <20060111003747.GJ3911@stusta.de> <1136940409.3435.126.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@stusta.de>, jgarzik@pobox.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161065AbWAKBpp@vger.kernel.org>
To: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <1136940409.3435.126.camel@localhost.localdomain>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 11 January 2006 01:46, David Woodhouse wrote:
> On Wed, 2006-01-11 at 01:37 +0100, Adrian Bunk wrote:
> > shadow.cabi.net does no longer exist.
> 
> Surely it would be better to point to the new home of these tools rather
> than removing the reference to them entirely?

shaper is completely obsolete and it's probably best to just remove
all references to it and the kernel driver too.

-Andi
