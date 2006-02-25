From: John Reiser <jreiser@BitWagon.com>
Subject: Re: [PATCH] Add Wake on LAN support to sis900 (2)
Date: Fri, 24 Feb 2006 16:08:10 -0800
Message-ID: <43FF9FEA.6030902@BitWagon.com>
References: <200601050223.k052Ngu2003866@hera.kernel.org> <20060224025759.GA14027@redhat.com> <5698750A-4231-4500-B060-B06165E5C0FD@brownhat.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964812AbWBYAIZ@vger.kernel.org>
To: Daniele Venzano <venza@brownhat.org>
In-Reply-To: <5698750A-4231-4500-B060-B06165E5C0FD@brownhat.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniele Venzano wrote:
> Attached you find the patch that fixes two bugs in the WoL 
> implementation of sis900. The first causes hangs on some system on 
> driver load, the second causes troubles when disabling WoL support. 
> Both fixes are one liner and really simple. Patch is against latest 
> netdev-2.6 tree.

Thank you for your prompt attention.  The patch works for me
(my SiS 730 board now boots again) when applied to Fedora Core
kernel-2.6.15-1.1977_FC5 which claims to be 2.6.16rc4-git6
of 2006-02-23.

-- 
