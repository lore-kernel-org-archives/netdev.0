From: =?iso-8859-1?Q?Sjur_Br=E6ndeland?= <sjur.brandeland@stericsson.com>
Subject: RE: [5/8,RFC] CAIF Protocol Stack
Date: Tue, 6 Oct 2009 21:01:24 +0200
Message-ID: <61D8D34BB13CFE408D154529C120E07902ED6713@eseldmw101.eemea.ericsson.se>
References: <1253727086-10353-1-git-send-email-sjur.brandeland@stericsson.com> <4ACA0DB7.5000802@babic.homelinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>,
	"Kim Lilliestierna XX" <kim.xx.lilliestierna@stericsson.com>
To: "Stefano Babic" <stefano.babic@babic.homelinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw5.ericsson.se ([193.180.251.36]:52620 "EHLO
	mailgw5.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757654AbZJFTCi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 15:02:38 -0400
Content-class: urn:content-classes:message
In-Reply-To: <4ACA0DB7.5000802@babic.homelinux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stefano Babic wrote:
>> +obj-$(CAIF_CHRDEV) +=3D chnl_chr.o
> Probably this should be obj-$(CONFIG_CAIF_CHARDEV) +=3D chnl_chr.o
>> +obj-$(CAIF_NETDEV) +=3D chnl_net.o
>Should be maybe CONFIG_CAIF_NETDEV ?

Thanks, it will be fixed in the patch-set sent out this week.

BR/Sjur Br=E6ndeland
