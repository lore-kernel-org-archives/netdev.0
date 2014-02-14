From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next v5 00/10] Support for the Broadcom GENET driver
Date: Fri, 14 Feb 2014 10:19:43 +0100
Message-ID: <20140214091943.GB3906@netboy>
References: <1392336531-28875-1-git-send-email-f.fainelli@gmail.com>
 <20140214.002901.293996041341946875.davem@davemloft.net>
 <52FDC094.1020104@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, cernekee@gmail.com,
	mark.rutland@arm.com, romieu@fr.zoreil.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f49.google.com ([74.125.83.49]:44094 "EHLO
	mail-ee0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752480AbaBNJTs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 04:19:48 -0500
Content-Disposition: inline
In-Reply-To: <52FDC094.1020104@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 13, 2014 at 11:07:00PM -0800, Florian Fainelli wrote:
> Le 13/02/2014 21:29, David Miller a =E9crit :
> >Series applied, thanks.
>=20
> Great, thanks David!

Sorry for the late comment, but how about adding a call to
skb_tx_timestamp(), in order to support so_timestamping?

Thanks,
Richard
