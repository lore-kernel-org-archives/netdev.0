From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: BCM43224 hanging [3.2.0-rc5]
Date: Thu, 22 Dec 2011 14:19:07 +0100
Message-ID: <4EF32E4B.7050307@broadcom.com>
References: <20111201224851.GB20536@ethz.ch>
 <4ED8B610.2010703@broadcom.com> <20111202150128.GC3096@schottelius.org>
 <20111207190821.GA1775@schottelius.org>
 <20111212181619.GD1975@schottelius.org> <20111214112148.GE3191@ethz.ch>
 <20111222102408.GA2643@schottelius.org>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit
To: "Nico Schottelius" <nico-linux-20111201@schottelius.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	b43-dev@lists.infradead.org, "Greg KH" <gregkh@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111222102408.GA2643@schottelius.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/22/2011 11:24 AM, Nico Schottelius wrote:
> Update:
> 
> - dmesg with hanging logs
> - The hang problem seems to happen ONLY with a specific access point: c8:6c:87:a9:df:a9
>   -> this is a zyxel P-2802HWL-I1, running at channel 13, with WPA2-PSK.
>   -> If you need more information, just let me know
> - Using wlan with the Samsung S2 as access point seems to work fine

Is the Samsung AP also on channel 13? If not, could you try it?

> So this is now a rather specific issue, but I guess others will run into
> this sooner or later as well.
> 
> Attached dmesg with hanging processes including traceback.
> 
> Nico
> 

Gr. AvS
