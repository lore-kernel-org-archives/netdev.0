From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [patch 1/2] net, bridge: align br_nf_ops assignment
Date: Sat, 11 Jul 2009 18:30:52 +0400
Message-ID: <20090711143052.GB5325@lenovo>
References: <20090704061156.658235360@openvz.org> <20090704062320.774818680@openvz.org> <20090709125500.5f8cf2a0@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:61316 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751676AbZGKOaz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jul 2009 10:30:55 -0400
Received: by fg-out-1718.google.com with SMTP id e12so174876fga.17
        for <netdev@vger.kernel.org>; Sat, 11 Jul 2009 07:30:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090709125500.5f8cf2a0@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Stephen Hemminger - Thu, Jul 09, 2009 at 12:55:00PM -0700]
| On Sat, 04 Jul 2009 10:11:57 +0400
| Cyrill Gorcunov <gorcunov@openvz.org> wrote:
| 
| > No functional change -- just for easier reading.
| > 
| > Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
| > ---
| >  net/bridge/br_netfilter.c |   96 ++++++++++++++++++++++++++--------------------
| >  1 file changed, 56 insertions(+), 40 deletions(-)
| > 
| 
| 
| Acked-by: Stephen Hemminger <shemminger@vyatta.com>
| 
| -- 
| 

Thanks for review Stephen. Will you pick them up?

	-- Cyrill
