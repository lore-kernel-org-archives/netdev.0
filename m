From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch iproute2 net-next-for-3.13 0/2] iplink: add support for
 bonding slave
Date: Mon, 17 Feb 2014 10:57:32 -0800
Message-ID: <20140217105732.6598d4ee@nehalam.linuxnetplumber.net>
References: <1390495974-11234-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, fubar@us.ibm.com,
	vfalico@redhat.com, andy@greyhouse.net,
	sfeldma@cumulusnetworks.com, john.r.fastabend@intel.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35446 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753108AbaBQS5f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 13:57:35 -0500
Received: by mail-pa0-f51.google.com with SMTP id ld10so15620059pab.24
        for <netdev@vger.kernel.org>; Mon, 17 Feb 2014 10:57:35 -0800 (PST)
In-Reply-To: <1390495974-11234-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Jan 2014 17:52:52 +0100
Jiri Pirko <jiri@resnulli.us> wrote:

> Jiri Pirko (2):
>   introduce support for slave info data
>   iplink: add support for bonding slave
> 
>  include/linux/if_link.h | 19 ++++++-----
>  ip/Makefile             |  2 +-
>  ip/ip_common.h          |  4 +++
>  ip/ipaddress.c          | 54 +++++++++++++++++++----------
>  ip/iplink.c             | 21 ++++++++++--
>  ip/iplink_bond_slave.c  | 90 +++++++++++++++++++++++++++++++++++++++++++++++++
>  6 files changed, 160 insertions(+), 30 deletions(-)
>  create mode 100644 ip/iplink_bond_slave.c
> 

Both applied - header was already updated.
