From: Bharath Ramesh <krosswindz@gmail.com>
Subject: Re: IPW2100 Kconfig
Date: Thu, 8 Sep 2005 17:11:42 -0400
Message-ID: <c775eb9b05090814114f258dc9@mail.gmail.com>
References: <005101c5b311_4ca69a50_a20cc60a@amer.sykes.com>
	 <20050908080106.GB773@openzaurus.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Alejandro Bonilla <abonilla@linuxwireless.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751399AbVIHVLo@vger.kernel.org>
To: Pavel Machek <pavel@ucw.cz>
In-Reply-To: <20050908080106.GB773@openzaurus.ucw.cz>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

AFAIK hotplug looks for firmware in /lib/firmware and not /etc/firmware.

On 9/8/05, Pavel Machek <pavel@ucw.cz> wrote:
> Hi!
> 
> >       I checked the IPW2100 in the current git from linux-2.6 and the menuconfig
> > help (Kconfig) says you need to put the firmware in /etc/firmware, it should
> > be /lib/firmware.
> >
> > Who should I send the "patch" to? Or can someone simply change that?
> 
> Are you sure it is not distro-dependend?
> --
> 64 bytes from 195.113.31.123: icmp_seq=28 ttl=51 time=448769.1 ms
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>
