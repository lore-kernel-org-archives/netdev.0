From: Mike_Phillips@URSCorp.com
Subject: Re: [PATCH] ibmtr init section usage
Date: Mon, 8 Mar 2004 09:39:52 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF771FE017.1DA04DD7-ON85256E51.0050720A-85256E51.00508E13@urscorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Randy.Dunlap" <rddunlap@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


>probe functions can be __devinit.

> Patch is to 2.6.4-rc2.  Please apply.

Will this blow up the pcmcia ibmtr_cs. It links in ibmtr and uses the probe
functions.

Mike
