From: Holger Schurig <hs4233-x6+DxXLjN1AJvtFkdXX2Hg4jNU5vUVPG@public.gmane.org>
Subject: Re: [PATCH 10/10] ieee802154: add at86rf230/rf231 spi driver
Date: Tue, 2 Jun 2009 10:10:49 +0200
Message-ID: <200906021010.49613.hs4233@mail.mn-solutions.de>
References: <1243868091-5315-3-git-send-email-dbaryshkov@gmail.com> <69e28c910906010921r56cf7017gc858cb7ba819c385@mail.gmail.com> <20090601203348.GC7143@doriath.ww600.siemens.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	=?iso-8859-1?q?G=E1bor_Stefanik?= <netrolller.3d-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org, maxim.osipov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org,
	dmitry.baryshkov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org, oliver.fendt-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090601203348.GC7143-nIupHZaCssqR2kOLt6zJ8ErlnG4Plg33XqFh9Ls21Oc@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> I thought about drivers/net as about ip (well, more or less)
> network drivers. We have drivers/atm or drivers/bluetooth (and
> bluetooth is 802.15.1...).

I actually like that this is drivers/bluetooth and not 
drivers/ieee802151. Would you consider drivers/zigbee instead of 
drivers/ieee802154 ???
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
