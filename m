From: Pavel Machek <pavel@ucw.cz>
Subject: Re: ipw2100: firmware problem
Date: Fri, 10 Jun 2005 11:00:23 +0200
Message-ID: <20050610090022.GF4173@elf.ucw.cz>
References: <200506090909.55889.vda@ilport.com.ua> <20050608.231657.59660080.davem@davemloft.net> <20050609104205.GD3169@elf.ucw.cz> <20050609.125324.88476545.davem@davemloft.net> <42A8AE2A.4080104@linux.intel.com> <42A8F758.2060008@pobox.com> <42A8FF03.3010508@linuxwireless.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>,
	James Ketrenos <jketreno@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>, vda@ilport.com.ua,
	netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
	ipw2100-admin@linux.intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262519AbVFJJAs@vger.kernel.org>
To: Alejandro Bonilla <abonilla@linuxwireless.org>
Content-Disposition: inline
In-Reply-To: <42A8FF03.3010508@linuxwireless.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> OK. I understand the point and I totally agree with this. We really want 
> the adapter to just do what the user or profiles ask the adapter to do. 
> Yes, in an ideal world.
> 
> Let's talk about easyness. These adapters are in laptops. You don't want 
> to type a lot of stop everytime you move from access points, reboots
> and 

We are not trying to make it hard to the users. Lets do the right
thing in kernel, and let userspace make it easy.
								Pavel
