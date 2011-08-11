From: Alan Cox <alan@linux.intel.com>
Subject: Re: [net-next 02/10] 3c*/acenic/typhoon: Move 3Com Ethernet drivers
Date: Thu, 11 Aug 2011 10:58:39 +0100
Message-ID: <20110811105839.12694227@bob.linux.org.uk>
References: <1313033278-7337-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1313033278-7337-3-git-send-email-jeffrey.t.kirsher@intel.com>
	<20110811100255.421a5fbc@bob.linux.org.uk>
	<1313054026.2339.3.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@tredhat.com" <gospo@tredhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	David Dillow <dave@thedillows.org>,
	Jes Sorensen <jes@trained-monkey.org>,
	David Hinds <dahinds@users.sourceforge.net>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:8361 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754492Ab1HKJy4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Aug 2011 05:54:56 -0400
In-Reply-To: <1313054026.2339.3.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Where would you like to put it? drivers/net/ethernet/alteon/?  I am
> fine with fixing this up by placing somewhere else.

If you are going by chip vendor then I guess yes it goes into alteon.

