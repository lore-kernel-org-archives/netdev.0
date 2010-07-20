From: Stefan Assmann <sassmann@redhat.com>
Subject: Re: [PATCH net-next] sysfs: add entry to indicate network interfaces
 with random MAC address
Date: Tue, 20 Jul 2010 14:17:30 +0200
Message-ID: <4C4593DA.9040207@redhat.com>
References: <4C457F72.8090708@redhat.com> <1279624844.2110.3.camel@achroite.uk.solarflarecom.com> <4C458CB7.3030508@redhat.com> <4C458F50.4070200@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	davem@davemloft.net, Andy Gospodarek <gospo@redhat.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	Casey Leedom <leedom@chelsio.com>,
	Harald Hoyer <harald@redhat.com>
To: Alex Badea <abadea@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16803 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758196Ab0GTMRm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jul 2010 08:17:42 -0400
In-Reply-To: <4C458F50.4070200@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20.07.2010 13:58, Alex Badea wrote:
> Hi,
> 
> On 07/20/2010 02:47 PM, Stefan Assmann wrote:
>>> What about devices that 'steal' MAC addresses from slave devices?
> 
> Might I suggest an attribute such as "address_type", which could report
> "permanent", "random", "stolen", or something else in the future?

In case there's demand for such a multi-purpose attribute I see no
reason to object. More thoughts on this?

Thanks for your suggestion Alex.

  Stefan
--
Stefan Assmann         | Red Hat GmbH
Software Engineer      | Otto-Hahn-Strasse 20, 85609 Dornach
                       | HR: Amtsgericht Muenchen HRB 153243
                       | GF: Brendan Lane, Charlie Peters,
sassmann at redhat.com |     Michael Cunningham, Charles Cachera
