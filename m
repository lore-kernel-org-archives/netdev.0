From: Angus Gibson <angus@agibson.me>
Subject: Re: [RFC PATCH linux-next] et131x: Promote staging et131x driver to
 drivers/net
Date: Tue, 23 Sep 2014 09:56:53 +1000
Message-ID: <20140922235653.GA17359@angus-mbp>
References: <1411421283-25073-1-git-send-email-mark.einon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	devel@driverdev.osuosl.org
To: mark.einon@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1411421283-25073-1-git-send-email-mark.einon@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +config NET_VENDOR_AGERE
> +	bool "Agere devices"
> +	default y
> +	depends on PCI
> +	---help---
> +	  If you have a network (Ethernet) card belonging to this class, say =
> Y
> +	  and read the Ethernet-HOWTO, available from
> +	  <http://www.tldp.org/docs.html#howto>.
> +
> +	  Note that the answer to this question doesn't directly affect the
> +	  kernel: saying N will just cause the configurator to skip all
> +	  the questions about Atheros devices. If you say Y, you will be aske=
should this be "Agere devices" instead?
> d
> +	  for your specific card in the following questions.
