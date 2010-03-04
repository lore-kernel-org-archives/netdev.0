From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/2] iproute2 skbedit: Add support to mark packets
Date: Wed, 03 Mar 2010 21:51:31 -0500
Message-ID: <1267671091.4821.27.camel@bigi>
References: <1259847168.3766.40.camel@bigi>
	 <20100303163638.09520577@nehalam>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:34955 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752032Ab0CDCve (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 21:51:34 -0500
Received: by qw-out-2122.google.com with SMTP id 5so86966qwd.37
        for <netdev@vger.kernel.org>; Wed, 03 Mar 2010 18:51:33 -0800 (PST)
In-Reply-To: <20100303163638.09520577@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

You applied 2/2 but not 1/2.

cheers,
jamal
On Wed, 2010-03-03 at 16:36 -0800, Stephen Hemminger wrote:
> On Thu, 03 Dec 2009 08:32:48 -0500
> jamal <hadi@cyberus.ca> wrote:
> 
> > I did this originally because i was getting too many support
> > questions on ipt with mark. It still makes sense since skbedit
> > seems to be the mother action of skb metadata (should probably
> > have been called skbmeta).
> > 
> > cheers,
> > jamal
> 
> 
> Applied
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

