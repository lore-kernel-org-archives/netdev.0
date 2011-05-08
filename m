From: =?UTF-8?B?SMOla29uIEzDuHZkYWw=?= <hlovdal@gmail.com>
Subject: Re: [PATCH] net/bonding: adjust codingstyle for bond_3ad files
Date: Mon, 9 May 2011 01:08:44 +0200
Message-ID: <BANLkTik_gMCHYp4sOnzzR1Gs=bn2pkpjfQ@mail.gmail.com>
References: <20110507012717.GA15854@x61.tchesoft.com>
	<1304733100.11874.33.camel@Joe-Laptop>
	<20110507173141.GA4204@x61.tchesoft.com>
	<1304791360.1738.6.camel@Joe-Laptop>
	<BANLkTimKs39m_htMFEygR+3Bfu7Butc-zQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joe Perches <joe@perches.com>, aquini@linux.com,
	kernel-janitors@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org, Nicolas Kaiser <nikai@nikai.net>
To: matt mooney <mfmooney@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:52095 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753886Ab1EHXIp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 19:08:45 -0400
In-Reply-To: <BANLkTimKs39m_htMFEygR+3Bfu7Butc-zQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7 May 2011 21:35, matt mooney <mfmooney@gmail.com> wrote:
> But isn't the preferred style to have a single exit point?

This is generally considered to be a bad advice, see
http://stackoverflow.com/questions/1701686/why-should-methods-have-a-si=
ngle-entry-and-exit-points/1701721#1701721
for instance.

BR H=C3=A5kon L=C3=B8vdal
