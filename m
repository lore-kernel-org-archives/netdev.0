From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [d80211] connecting to B-mode AP
Date: Sat, 16 Sep 2006 17:34:34 +0200
Message-ID: <200609161734.35091.mb@bu3sch.de>
References: <C86180A8C204554D8A3323D8F6B0A29F01785374@dhost002-46.dex002.intermedia.net> <450B3C51.208@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Simon Barber <simon@devicescape.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:47308
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S932393AbWIPPgL
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Sep 2006 11:36:11 -0400
To: mabbas <mabbas@linux.intel.com>
In-Reply-To: <450B3C51.208@linux.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 16 September 2006 01:50, mabbas wrote:
> I see your point here, although some one will file some bugs against the 
> driver about showing G while associating with B-mode AP. By the way how 
> can you figure if the AP is B/G other than the rates?

I don't think this will happen.
This never happened with bcm43xx, for example. The PHY description
of the card is something _completely_ different than the AP's PHY.
People know that G is backwards compatible to B. And people who don't
even know that, don't care anyway. ;)

-- 
Greetings Michael.
