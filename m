From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [WIP][PATCHES] Network xmit batching
Date: Sat, 9 Jun 2007 01:02:33 +0400
Message-ID: <20070608210233.GA27925@2ka.mipt.ru>
References: <OFB311484E.057E34E9-ON652572F3.001D5838-652572F3.0022766D@in.ibm.com> <1181216629.4064.22.camel@localhost> <20070607161335.GA4987@2ka.mipt.ru> <1181254996.4071.27.camel@localhost> <20070608083807.GB11488@2ka.mipt.ru> <1181302267.4063.33.camel@localhost> <20070608120904.GA19011@2ka.mipt.ru> <1181308067.4063.120.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	Gagan Arneja <gaagaan@gmail.com>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	Robert Olsson <Robert.Olsson@data.slu.se>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:58870 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751079AbXFHVIJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jun 2007 17:08:09 -0400
Content-Disposition: inline
In-Reply-To: <1181308067.4063.120.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 08, 2007 at 09:07:47AM -0400, jamal (hadi@cyberus.ca) wrote:
> > Something, that anyone can understand :)
> > For example /proc stats, although it is not very accurate, but it is
> > really usable parameter from userspace point ov view.
> 
> which /proc stats?

/proc/$pid/stat, for pktgen it is likely not that interesting, but for
usual userspace applcation it is quite interesting parameter.
At least that is what 'top' shows.
 
-- 
	Evgeniy Polyakov
