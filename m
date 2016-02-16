From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [Intel-wired-lan] [next] igb: allow setting MAC address on i211
 using a device tree blob V2
Date: Tue, 16 Feb 2016 23:47:25 +0100
Message-ID: <20160216224725.GC6033@lunn.ch>
References: <56BFA87D.1010609@gmail.com>
 <20160216165850.GF29482@lunn.ch>
 <255BB17A-515B-467A-8ED6-96F1173D233E@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: John Holland <jotihojr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47865 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756143AbcBPWr3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2016 17:47:29 -0500
Content-Disposition: inline
In-Reply-To: <255BB17A-515B-467A-8ED6-96F1173D233E@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I can supply some kind of usage description/example, showing how to
> use this feature to pull in the MAC address from u-boot and route it
> to the i210. Just uncertain as how to name the respective
> file. igb.txt or i210.txt come to mind. Do you prefer one over the
> other?

Hi John

It is quite common to name it after the compatible string, so
intel,i210.txt

Thanks
	Andrew
