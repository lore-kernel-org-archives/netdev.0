From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: wireless notes / pre d80211 merge
Date: Wed, 15 Nov 2006 13:47:47 -0500
Message-ID: <455B60D3.5050108@pobox.com>
References: <20061115011123.0eb1eff6@logostar.upir.cz>	<C86180A8C204554D8A3323D8F6B0A29F0192722C@dhost002-46.dex002.intermedia.net> <20061115104359.3ce80e3b@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Simon Barber <simon@devicescape.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Michael Buesch <mbuesch@freenet.de>,
	Ivo van Doorn <ivdoorn@gmail.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Jouni Malinen <jkm@devicescape.com>,
	Daniel Drake <dsd@gentoo.org>, Hong Liu <hong.liu@intel.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	James Ketrenos <jketreno@linux.intel.com>,
	David Kimdon <dwhedon@devicescape.com>,
	Udayan Singh <udayan.singh@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:22672 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1030863AbWKOSsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Nov 2006 13:48:01 -0500
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20061115104359.3ce80e3b@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri Benc wrote:
> On Tue, 14 Nov 2006 18:10:50 -0800, Simon Barber wrote:
>> I disagree that the master device is a hack
> 
> It's a clever hack but still a hack. The Linux network interfaces
> wasn't designed for the sort of things we do with master interface.
> Actually, the networking core doesn't support the concept of "wiphys"
> at all. Yes, Jouni found a really clever way around this. But the most
> correct solution is different.

Agreed.

	Jeff


