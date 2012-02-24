From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH 09/11] usb/kaweth: print MAC via printk format specifier
Date: Fri, 24 Feb 2012 14:56:37 +0100
Message-ID: <201202241456.37306.oliver@neukum.org>
References: <1330091162-8141-1-git-send-email-danny.kukawka@bisect.de> <1330091162-8141-10-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
	Danny Kukawka <dkukawka@suse.de>, linux-usb@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Danny Kukawka <danny.kukawka@bisect.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330091162-8141-10-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Freitag, 24. Februar 2012, 14:46:00 schrieb Danny Kukawka:
> Print MAC/dev_addr via printk extended format specifier %pM
> instead of custom code.
> 
> Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
Acked-by: Oliver Neukum <oliver@neukum.name>
