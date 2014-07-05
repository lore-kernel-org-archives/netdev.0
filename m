From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next repost v2 3/3] vlan: Pass SIOC[SG]HWTSTAMP
 ioctls to real device
Date: Sat, 5 Jul 2014 20:59:36 +0200
Message-ID: <20140705185936.GB3869@localhost.localdomain>
References: <1404312104-19154-1-git-send-email-stefan.sorensen@spectralink.com>
 <1404312104-19154-4-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, kaber@trash.net, netdev@vger.kernel.org
To: Stefan =?iso-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectralink.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:38711 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752338AbaGETAA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jul 2014 15:00:00 -0400
Received: by mail-we0-f179.google.com with SMTP id w62so2754184wes.38
        for <netdev@vger.kernel.org>; Sat, 05 Jul 2014 11:59:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1404312104-19154-4-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 02, 2014 at 04:41:44PM +0200, Stefan S=F8rensen wrote:
> This allows applications to enable hardware timestamping without bein=
g aware
> of it being a vlan device and figuring out the real device.
>=20
> Signed-off-by: Stefan S=F8rensen <stefan.sorensen@spectralink.com>

Acked-by: Richard Cochran <richardcochran@gmail.com>
