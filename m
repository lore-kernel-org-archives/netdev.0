From: jamal <hadi@cyberus.ca>
Subject: Re: [patch 2.6.13 0/5] normalize calculations of rx_dropped
Date: Mon, 24 Oct 2005 21:42:18 -0400
Message-ID: <1130204538.6187.20.camel@localhost.localdomain>
References: <09122005104858.332@bilbo.tuxdriver.com>
	 <4325CEAB.2050600@pobox.com> <20050912191419.GB19644@tuxdriver.com>
	 <435D53AE.3020401@candelatech.com> <20051024215751.GH28212@tuxdriver.com>
	 <435D8717.9000107@candelatech.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751324AbVJYBmi@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <435D8717.9000107@candelatech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2005-24-10 at 18:15 -0700, Ben Greear wrote:
[..]
> That way, the rx-errors counter can be used for folks who just care
> that the packet was not correctly received, and those that care about
> the details can look at the individual errors (and sum them up in various
> configurations due to personal taste, etc.)
> 

Look at http://www.faqs.org/rfcs/rfc2665.html
for a more finer breakdown.

rx/tx_errors may be further broken down.

cheers,
jamal
