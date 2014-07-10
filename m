From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next] dp83640: Adjust ptp event timestamps
Date: Thu, 10 Jul 2014 19:35:42 +0200
Message-ID: <20140710173542.GC7965@localhost.localdomain>
References: <1404901343-19445-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stefan =?iso-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectralink.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:50081 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751404AbaGJRgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 13:36:05 -0400
Received: by mail-wi0-f173.google.com with SMTP id cc10so5008046wib.12
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 10:36:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1404901343-19445-1-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 09, 2014 at 12:22:23PM +0200, Stefan S=F8rensen wrote:
> From the dp86340 Software Development Guide:
>   Event timestamp values should be adjusted by 3*reference clock peri=
od +
>   11 ns =3D 35 ns to compensate for input path and synchronization de=
lays.
>=20
> So subtract 35ns from event timestamps.
>=20
> Signed-off-by: Stefan S=F8rensen <stefan.sorensen@spectralink.com>

Acked-by: Richard Cochran <richardcochran@gmail.com>
