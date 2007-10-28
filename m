From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: 2.6.24-rc1 kills onboard r8169 (rtl8111b) NIC
Date: Sun, 28 Oct 2007 22:16:00 +0100
Message-ID: <20071028211600.GA28735@electric-eye.fr.zoreil.com>
References: <d6a046090710281254k149e300alc66266f241ccdf03@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Alexander Y. Fomichev" <gluk@php4.ru>
To: "Sergey S. Kostyliov" <rathamahata@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754688AbXJ1VWd@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <d6a046090710281254k149e300alc66266f241ccdf03@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sergey S. Kostyliov <rathamahata@gmail.com> :
[...]
> After booting 2.6.24-rc1 on my home machine I lost onboard rtl8111b
> network card. It is neither functional nor even visible by lspci
> anymore.
> 
> Moreover rebooting to previous 2.6.23-rc9 didn't fix it - card was
> still not available.

It should reappear after some time at rest. Until I come with
something better, you should use 2.6.24-rc with the r8169 driver from
2.6.23.

-- 
Ueimor
