From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2 0/3] net: via-rhine: add support for on-chip Rhine
 controllers
Date: Wed, 23 Apr 2014 15:26:53 -0400 (EDT)
Message-ID: <20140423.152653.2008980151348280912.davem@davemloft.net>
References: <1390823503-24087-1-git-send-email-alchark@gmail.com>
	<1398180489-20230-1-git-send-email-alchark@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rl-7uj+XXdSDtwfv37vnLkPlQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ci5G2KO2hbZ+pU9mqzGVBQ@public.gmane.org,
	robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org
To: alchark-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1398180489-20230-1-git-send-email-alchark-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alexey Charkov <alchark-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Tue, 22 Apr 2014 19:28:06 +0400

> This series introduces platform bus (OpenFirmware) binding for 
> via-rhine, as used in various ARM-based Systems-on-Chip by 
> VIA/WonderMedia.
> 
> This has been tested in OF configuration by myself on a WM8950-based VIA 
> APC Rock development board and on a WM8850-based netbook, and in PCI
> configuration by Roger.
> 
> Please note that the initial version of these patches was signed off by
> Roger, but some time has passed since then, so I'm not including his
> sign-off until explicit notice.
> 
> David, could you please take these to net-next if appropriate?

Series applied to net-next, thanks Alexey.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
