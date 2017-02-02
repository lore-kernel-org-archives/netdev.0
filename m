From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: "TCP: eth0: Driver has suspect GRO implementation, TCP
 performance may be compromised." message with "ethtool -K eth0 gro off"
Date: Thu, 2 Feb 2017 13:34:27 +0100
Message-ID: <20170202123427.GA7212@x4>
References: <20170202115240.GH17590@x4>
 <1486038733.13103.21.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ud10.udmedia.de ([194.117.254.50]:51954 "EHLO
        mail.ud10.udmedia.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751350AbdBBMea (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 07:34:30 -0500
Content-Disposition: inline
In-Reply-To: <1486038733.13103.21.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017.02.02 at 04:32 -0800, Eric Dumazet wrote:
> On Thu, 2017-02-02 at 12:52 +0100, Markus Trippelsdorf wrote:
> > Hi,
> > 
> > from time to time I see the following warning in my kernel log:
> > 
> >  TCP: eth0: Driver has suspect GRO implementation, TCP performance may be compromised.
> > 
> > This happens although I run "/usr/sbin/ethtool -K eth0 gro off" in my
> > local boot script. 
> > What is the warning trying to tell me?
> > 
> 
> Please report
> 
> ethtool -i eth0

driver: ATL1E
version: 1.0.0.7-NAPI
firmware-version: L1e
expansion-rom-version:
bus-info: 0000:02:00.0
supports-statistics: no
supports-test: no
supports-eeprom-access: no
supports-register-dump: yes
supports-priv-flags: no

-- 
Markus
