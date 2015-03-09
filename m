From: Daniel =?iso-8859-1?Q?Gl=F6ckner?= <daniel-gl-hi6Y0CQ0nG0@public.gmane.org>
Subject: Re: BCM4313 & brcmsmac & 3.12: only semi-working?
Date: Mon, 9 Mar 2015 21:54:51 +0100
Message-ID: <20150309205451.GA13884@minime.bse>
References: <53FDACD1.8090805@msgid.tls.msk.ru>
 <9234001.YBqfvtcJFx@fuchs>
 <5496E135.1@broadcom.com>
 <9062978.Vq0rTjKd5z@fuchs>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Tokarev <mjt-XAri/EZa3C4vJsYlp49lxw@public.gmane.org>,
	=?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	brcm80211 development <brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Maximilian Engelhardt <maxi-OwNUvPV92VfddJNmlsFzeA@public.gmane.org>
To: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <9062978.Vq0rTjKd5z@fuchs>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Arend,

On Sun, Dec 21, 2014 at 06:34:24PM +0100, Maximilian Engelhardt wrote:
> On Sunday 21 December 2014 16:03:17 Arend van Spriel wrote:
> > On 12/21/14 15:24, Maximilian Engelhardt wrote:
> > > On Sunday 21 December 2014 15:13:50 Arend van Spriel wrote:
> > >> Thanks. It shows you have have the same bt-coex version as Michael. I am
> > >> not familiar with bluetooth side of things. Are you both using bluetooth
> > >> on 4313?
> > >> 
> > >> Regards,
> > >> Arend
> > > 
> > > I don't know. I think I have Bluetooth somehow enabled but I'm not really
> > > using it. I definitely don't have any Bluetooth devices connected. I could
> > > try to unload/disable Bluetooth it to see if it makes any difference.
> > 
> > That would be useful to know.
> > 
> 
> I did a test with all Bluetooth modules unloaded that I could find but 
> throughput was still very low (about 4 Mbit/s with brcmsmac, my atheros USB 
> stick archived about 110 Mbit/s).

any update on this issue?
One of my relatives would like to get rid of that Ralink wifi stick she
has been carrying around for 1.5 years now since the internal wifi in her
Thinkpad E130 suffers from this problem.

Best regards,

  Daniel
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
