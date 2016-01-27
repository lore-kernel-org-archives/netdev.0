From: Jiri Pirko <jiri@resnulli.us>
Subject: switchdev automated testing
Date: Wed, 27 Jan 2016 15:46:57 +0100
Message-ID: <20160127144657.GB2222@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, jhs@mojatatu.com,
	sfeldma@gmail.com, vivien.didelot@savoirfairelinux.com,
	f.fainelli@gmail.com, linux@roeck-us.net, andrew@lunn.ch,
	gospo@cumulusnetworks.com, roopa@cumulusnetworks.com,
	rami.rosen@intel.com, nikolay@cumulusnetworks.com,
	horms@verge.net.au, pjonnala@broadcom.com, olichtne@redhat.com,
	jtluka@redhat.com, jprochaz@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33615 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932555AbcA0OrA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2016 09:47:00 -0500
Received: by mail-wm0-f66.google.com with SMTP id r129so3787944wmr.0
        for <netdev@vger.kernel.org>; Wed, 27 Jan 2016 06:46:59 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All.

Just want to send a small note here about what we use for mlxsw driver
automated testing. It can be handy for other people using switchdev
infra, namely DSA guys.

The framework is called LNST:
http://lnst-project.org/

Switchdev recipes are located in LNST git repo here:
https://github.com/jpirko/lnst/tree/master/recipes/switchdev

It's just a start. We'd like to make them more complete, possibly with
your help.

LNST can be of course used for other network automated testing purposes.
Ccing LNST developers (jtluka, olichtne, jprochaz). Feel free to ask me
or them any questions.

Thanks.

Jiri
