From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: [-mm patch] drivers/net/wireless/tiacx/: add missing #include <linux/vmalloc.h>'a
Date: Sat, 12 Nov 2005 14:02:01 +0200
Message-ID: <200511121402.01465.vda@ilport.com.ua>
References: <20051111200735.GO5376@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932363AbVKLMCn@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20051111200735.GO5376@stusta.de>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 11 November 2005 22:07, Adrian Bunk wrote:
> This is required for always getting the vmalloc()/vfree() prototypes.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Applied, thanks.
--
vda
