From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH 1/1] gtp: support SGSN-side tunnels
Date: Wed, 15 Mar 2017 17:39:16 +0100
Message-ID: <20170315163916.gins7lzzqhwkvfrc@nataraja>
References: <20170203091231.10142-1-jonas@southpole.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, netdev@vger.kernel.org
To: Jonas Bonn <jonas@southpole.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:54652 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753405AbdCORPH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 13:15:07 -0400
Content-Disposition: inline
In-Reply-To: <20170203091231.10142-1-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jonas,

are you working on the review feedback that was provided back in early
February?  I think there were some comments like
* remove unrelated cosmetic change in comment
* change from FLAGS to a dedicated MODE netlink attribute
* add libgtpnl code and some usage information or even sample scripts

I would definitely like to see this move forward, particularly in order
to test the GGSN-side code.

Regards,
	Harald
-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
