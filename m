From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [2.6 patch] drivers/net/arcnet/: possible cleanups
Date: Tue, 17 Jan 2006 08:38:25 -0500
Message-ID: <43CCF351.2050004@pobox.com>
References: <20060114021022.GE29663@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932480AbWAQNib@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20060114021022.GE29663@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> This patch contains the following possible cleanups:
> - make needlessly global code static
> - arcnet.c: remove the unneeded EXPORT_SYMBOL(arc_proto_null)
> - arcnet.c: remove the unneeded EXPORT_SYMBOL(arcnet_dump_packet)
> 
> To make Jeff happy, arcnet.c still prints
>   arcnet: v3.93 BETA 2000/04/29 - by Avery Pennarun et al.
> 
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

applied
