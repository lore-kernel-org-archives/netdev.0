From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: [DOC]: generic netlink
Date: Thu, 13 Jul 2006 10:50:28 -0700
Message-ID: <20060713105028.b262b95e.rdunlap@xenotime.net>
References: <1150724482.5815.48.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, tgraf@suug.ch,
	jlan@engr.sgi.com, nagar@watson.ibm.com, per.liden@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:26274 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S964776AbWGMRrn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2006 13:47:43 -0400
Received: from midway.site ([71.117.253.75]) by xenotime.net for <netdev@vger.kernel.org>; Thu, 13 Jul 2006 10:47:39 -0700
To: hadi@cyberus.ca
In-Reply-To: <1150724482.5815.48.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 19 Jun 2006 09:41:22 -0400 jamal wrote:

> 
> Folks,
> 
> Attached is a document that should help people wishing to use generic
> netlink interface. It is a WIP so a lot more to go if i see interest.

Hi,
I have a few random questions about gen-netlink.

1.  Provider IDs (numbers) and names must be unique.  Does
this affect virtualization in any way or is it just transparent?

2.  Is (generic) netlink meant (expected, OK) to be used for
non-networking ioctl/sysfs replacements?

Thanks,
---
~Randy
