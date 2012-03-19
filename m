From: Mohammed Shafi <shafi.wireless@gmail.com>
Subject: Re: ath: DMA failed to stop in 10 ms AR_CR=0x00000024
 AR_DIAG_SW=0x02000020 DMADBG_7=0x00008040
Date: Mon, 19 Mar 2012 20:50:25 +0530
Message-ID: <CAD2nsn3xpkGenrK50YmE5D7Odg3sBEek5zKcLZF6MAm69p5RJg@mail.gmail.com>
References: <4F576FD5.2050208@gmail.com>
	<CAD2nsn23UqshHz1ZUn8bHN0rWyOMbBHhn9V8pmCc4_aT_uGYaw@mail.gmail.com>
	<4F577D9B.7020402@gmail.com>
	<4F579A88.6030503@openwrt.org>
	<4F61F551.5010608@gmail.com>
	<4F639851.5080500@gmail.com>
	<4F674616.8080103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux-wireless <linux-wireless@vger.kernel.org>,
	Felix Fietkau <nbd@openwrt.org>, linux-kernel@vger.kernel.org,
	Linux-netdev <netdev@vger.kernel.org>
To: "Justin P. Mattock" <justinmattock@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F674616.8080103@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Justin,

> seems I got this when waking up from suspend, was trying to connect with NM
> then all of a sudden Xorg shut off and this appeared on the screen(image
> links below I could not save dmesg only pic)
> http://flic.kr/p/bEhf2K
> http://flic.kr/p/bEhf2x
> http://flic.kr/p/bEhf2n
> http://flic.kr/p/bEhf26
>
> I see ath9k in the image, but am unsure if its related.
> kernel is: 3.3.0-rc7-next-20120316

this looks like some new issue  in ath9k, lets try to recreate it here

>
> Justin P. Mattock
>
>
>



-- 
thanks,
shafi
