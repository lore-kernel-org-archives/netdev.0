From: "Alejandro Bonilla" <abonilla@linuxwireless.org>
Subject: RE: ipw2100: firmware problem
Date: Thu, 9 Jun 2005 08:31:51 -0600
Message-ID: <002a01c56cff$fb64ba70$600cc60a@amer.sykes.com>
References: <200506090909.55889.vda@ilport.com.ua>
Reply-To: <abonilla@linuxwireless.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262355AbVFIOcU@vger.kernel.org>
To: "'Denis Vlasenko'" <vda@ilport.com.ua>,
	"'Pavel Machek'" <pavel@ucw.cz>,
	"'Jeff Garzik'" <jgarzik@pobox.com>,
	"'Netdev list'" <netdev@oss.sgi.com>,
	"'kernel list'" <linux-kernel@vger.kernel.org>,
	"'James P. Ketrenos'" <ipw2100-admin@linux.intel.com>
In-Reply-To: <200506090909.55889.vda@ilport.com.ua>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> What is so nice about this? That Linux novice user with his new lappie
> will join a neighbor's network every time he powers up the lappie,
> even without knowing that?
>
> That will be analogous to me plugging ethernet cable into the
> switch and
> wanting it to work, without any IP addr config, even without
> DHCP client.
> Just power up the box (or modprobe an eth module) and it
> works! Cool, eh?
>

You want things one way, I like them in another way. Whoever makes this
decision should just know that we would like to have an option to make it
load with or without the ASSOC on.

James already said to use the options ipw2100 disable=1 if you don't want it
to associate everytime on boot.

At the end, who decides this?

.Alejandro


> For some reason, we do not do this for wired nets. Why should wireless
> be different?
> --
> vda
>
