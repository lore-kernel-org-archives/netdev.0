From: bert hubert <bert.hubert@netherlabs.nl>
Subject: Re: skb diet
Date: Sun, 16 Apr 2006 13:43:58 +0200
Message-ID: <20060416114358.GA12333@outpost.ds9a.nl>
References: <baebb9a00604150417h1ffb3f97g102253dca0b3a53e@mail.gmail.com> <200604152122.01914.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hisham Kotry <hkotry@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpost.ds9a.nl ([213.244.168.210]:9618 "EHLO outpost.ds9a.nl")
	by vger.kernel.org with ESMTP id S1750722AbWDPLoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Apr 2006 07:44:06 -0400
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <200604152122.01914.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 15, 2006 at 09:22:01PM +0200, Andi Kleen wrote:

> And optimizing for uncommon cases (not TCP) doesn't seem too useful.

There are servers that do tens of megabits of UDP these days (think VoIP, or
in my case, DNS), so it not that uncommon.

	Bert

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://netherlabs.nl              Open and Closed source services
