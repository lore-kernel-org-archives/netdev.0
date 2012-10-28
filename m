From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 00/16] treewide: Convert dev_printk(KERN_<LEVEL> to
 dev_<level>(
Date: Sun, 28 Oct 2012 05:12:15 -0700
Message-ID: <1351426335.2008.6.camel@joe-AO722>
References: <cover.1351411047.git.joe@perches.com>
	 <508D0ECA.8040008@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-ide-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-pcmcia-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devel-s9riP+hp16TNLxjTenLetw@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-watchdog-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org
To: Sergei Shtylyov <sshtylyov-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <508D0ECA.8040008-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, 2012-10-28 at 14:54 +0400, Sergei Shtylyov wrote:
> Hello.

Hi Sergei.

> On 28-10-2012 12:05, Joe Perches wrote:
> 
> > dev_<level> create smaller objects than dev_printk(KERN_<LEVEL>.
> > Convert non-debug calls to this form.
> 
> > Joe Perches (16):
> >    tile: Convert dev_printk(KERN_<LEVEL> to dev_<level>(
> [...]
> >    tile: Convert dev_printk(KERN_<LEVEL> to dev_<level>(
> [...]
> >    tile: Convert dev_printk(KERN_<LEVEL> to dev_<level>(
> 
>     Hm, somehow this patch is repeated thrice?

Nope, I forgot to edit the 0000 file after I edited
patches locally when I noticed I forgot to update
the subject lines.  Patches are corrected, 0000 not.

I don't think it's a bit deal, I could repost just the 0000
if you want though.

cheers, Joe
