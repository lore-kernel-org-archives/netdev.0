From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] net:phy:dp83640: Declare that TX timestamping possible
Date: Mon, 3 Feb 2014 17:19:35 +0100
Message-ID: <20140203161934.GB6011@netboy>
References: <1391438195-21888-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stefan =?iso-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectralink.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f172.google.com ([209.85.215.172]:51166 "EHLO
	mail-ea0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752350AbaBCQTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Feb 2014 11:19:40 -0500
Received: by mail-ea0-f172.google.com with SMTP id l9so2328025eaj.17
        for <netdev@vger.kernel.org>; Mon, 03 Feb 2014 08:19:40 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1391438195-21888-1-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 03, 2014 at 03:36:35PM +0100, Stefan S=F8rensen wrote:
> Set the SKBTX_IN_PROGRESS bit in tx_flags dp83640_txtstamp when doing
> tx timestamps as per Documentation/networking/timestamping.txt.
>=20
> Signed-off-by: Stefan S=F8rensen <stefan.sorensen@spectralink.com>
> ---

Acked-by: Richard Cochran <richardcochran@gmail.com>
