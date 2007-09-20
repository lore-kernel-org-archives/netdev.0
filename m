From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] NET_SB1250_MAC: Rename to SB1250_MAC
Date: Thu, 20 Sep 2007 00:11:46 -0400
Message-ID: <46F1F302.4050905@pobox.com>
References: <Pine.LNX.4.64N.0709141158010.1926@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	linux-mips@linux-mips.org, linux-kernel@vger.kernel.org
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756845AbXITEMz@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64N.0709141158010.1926@blysk.ds.pg.gda.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Maciej W. Rozycki wrote:
>  Rename NET_SB1250_MAC to SB1250_MAC to follow the convention.
> 
> Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
> ---
>  The NET prefix seems to be used mainly for device groups (NET_ISA, 
> NET_VENDOR_*, etc.) rather than single drivers and adds no information.  I 
> suggest it to be removed.
> 
>  Depends on "patch-netdev-2.6.23-rc6-20070913-sb1250-mac-kconfig-0".

applied
