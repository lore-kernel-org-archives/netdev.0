From: James Ketrenos <jketreno-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [ipw3945-devel] [ANNOUNCE] d80211 based driver for Intel PRO/Wireless
 3945ABG
Date: Tue, 13 Feb 2007 15:23:31 -0800
Message-ID: <45D24873.10308@linux.intel.com>
References: <45CCE3CA.4050904@linux.intel.com> <20070210004620.GA5959@gamma.logic.tuwien.ac.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ipw3945-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Norbert Preining <preining-DX+603jRYB8@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070210004620.GA5959-DqSSrKF0TaySnEC3TeqHn5dqbFPxfnh/@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Norbert Preining wrote:
...
> Ahhh ... one thing: The LED on my Acer Laptop (TM3012) does not show up,
> maybe because I have CONFIG_D80211_LEDS off?

The LED code in iwlwifi isn't hooked up to the D80211 LED code yet.  If 
you'd file a bug at http://bughost.org regarding the LEDs being broken 
(if you haven't already) I would appreciate it.

Thanks,
James
