From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Subject: Re: pull request: wireless-next-2.6 2009-10-28
Date: Thu, 29 Oct 2009 12:12:41 +0100
Message-ID: <200910291212.41656.bzolnier@gmail.com>
References: <20091028211031.GF2856@tuxdriver.com> <200910282256.00407.bzolnier@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:64151 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752676AbZJ2LNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 07:13:40 -0400
In-Reply-To: <200910282256.00407.bzolnier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 28 October 2009 22:56:00 Bartlomiej Zolnierkiewicz wrote:
> On Wednesday 28 October 2009 22:10:32 John W. Linville wrote:
> > Dave,
> > 
> > I let my patches pile-up!  Yikes!!
> > 
> > This request includes the usual ton of stuff for -next -- driver
> > updates, fixes for some earlier -next stuff, a few cfg80211 changes to
> > accomodate the libertas driver, etc.  Of note is the rt2800pci support
> > added to the rt2x00 family.
> 
> Unfortunately rt2800pci support is non-functioning at the moment... :(
> 
> > Pleaset let me know if there are problems!
> 
> I find it rather disappointing that all my review comments regarding
> rt2800pci support were just completely ignored and then the initial
> patch was merged just as it was..
> 
> The way rt2800usb and rt2800pci drivers are designed really results
> in making the task of adding working support for RT28x0 and RT30x0
> chipsets to rt2x00 infrastructure more difficult and time consuming
> than it should be... :(

What is even more disappointing (especially after all that "working with"
preaching) is that the patch is now in net-next-2.6..

-- 
Bartlomiej Zolnierkiewicz
