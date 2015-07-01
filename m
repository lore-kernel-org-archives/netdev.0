From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: =?utf-8?B?562U5aSNOiBhYm91?= =?utf-8?Q?t?= [PATCH]
 net:usb:cdc_ncm: fix that tag Huawei devices as wwan
Date: Tue, 30 Jun 2015 18:04:48 -0700
Message-ID: <20150701010448.GB15801@kroah.com>
References: <CA+55aFz3S3nR_aDMMS1vcayyEqJCBL5tgoYAfDE2WGyM3Vcrww@mail.gmail.com>
 <87ioapl55s.fsf@nemi.mork.no>
 <30508675-5839-4E65-975A-4CFC5B1C5E24@holtmann.org>
 <87a8w1kz3a.fsf@nemi.mork.no>
 <EA652056-E807-4977-AF2A-8BF7E3E41DFD@holtmann.org>
 <SNT147-W34897D8EB12DAD3DE657EDB3A60@phx.gbl>
 <SNT147-W52BB193529481B6D3BFA57B3AF0@phx.gbl>
 <73FEE7778B75214796F3C8DE1ABE6DD66ED26A22@szxema508-mbx.china.huawei.com>
 <87oak27rmn.fsf@nemi.mork.no>
 <73FEE7778B75214796F3C8DE1ABE6DD66ED26CD3@szxema508-mbx.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	"torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
	"aleksander@aleksander.es" <aleksander@aleksander.es>,
	"dcbw@redhat.com" <dcbw@redhat.com>,
	"oliver@neukum.org" <oliver@neukum.org>,
	"ben.hutchings@codethink.co.uk" <ben.hutchings@codethink.co.uk>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"marcel@holtmann.org" <marcel@holtmann.org>,
	"xiaomao0213@hotmail.com" <xiaomao0213@hotmail.com>,
	Zhangyuhan <zhangyuhan@huawei.com>,
	Maqianni <maqianni@huawei.com>
To: "Chenqi (jakio)" <cqi.chen@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:59350 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752352AbbGABEt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2015 21:04:49 -0400
Content-Disposition: inline
In-Reply-To: <73FEE7778B75214796F3C8DE1ABE6DD66ED26CD3@szxema508-mbx.china.huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 01, 2015 at 12:49:01AM +0000, Chenqi (jakio) wrote:
> Hi=EF=BC=8Cbjorn,
>=20
> Thanks for your kindly reply and providing so much info about linux w=
wan components!
>=20
> We'll make a deep research on linux wwan architecture, maybe we can s=
upport it in the newly developing products.
> About what you saying about "submit the patch formally", what steps s=
hould I do? Is there any documents about it?

The kernel source file, Documentation/SubmittingPatches describes the
steps and details everything you need to know about how to properly
submit a kernel patch.

thanks,

greg k-h
