From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] dp83640: Always decode received status frames
Date: Thu, 26 Jun 2014 07:07:19 +0200
Message-ID: <20140626050719.GA4537@netboy>
References: <1403700016-11398-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stefan =?iso-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectralink.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:51443 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751018AbaFZFHa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 01:07:30 -0400
Received: by mail-wg0-f48.google.com with SMTP id n12so3031040wgh.31
        for <netdev@vger.kernel.org>; Wed, 25 Jun 2014 22:07:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1403700016-11398-1-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 25, 2014 at 02:40:16PM +0200, Stefan S=F8rensen wrote:
> Currently status frames are only handled when packet timestamping is
> enabled, but status frames are also needed for pin event timestamping=
=2E
>=20
> Fix by moving packet timestamping check to after status frame decode.
>=20
> Signed-off-by: Stefan S=F8rensen <stefan.sorensen@spectralink.com>

Acked-by: Richard Cochran <richardcochran@gmail.com>
