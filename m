From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 5/5] dp83640: Only wait for timestamps for
 packets with timestamping enabled.
Date: Fri, 30 Oct 2015 21:40:07 +0100
Message-ID: <20151030204007.GF27879@netboy>
References: <1446207244-2206-1-git-send-email-stefan.sorensen@spectralink.com>
 <1446207244-2206-6-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stefan =?iso-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectralink.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:33487 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759823AbbJ3UkL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 16:40:11 -0400
Received: by wijp11 with SMTP id p11so18590019wij.0
        for <netdev@vger.kernel.org>; Fri, 30 Oct 2015 13:40:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1446207244-2206-6-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 30, 2015 at 01:14:04PM +0100, Stefan S=F8rensen wrote:
> In the packet timestamping function, check that the ptp version and
> protocol of the packet matches what we have configured the hardware t=
o
> actually generate timestamps for, before looking/waiting for a timest=
amp.
>=20
> Signed-off-by: Stefan S=F8rensen <stefan.sorensen@spectralink.com>

Acked-by: Richard Cochran <richardcochran@gmail.com>
