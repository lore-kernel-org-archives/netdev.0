From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 4/5] ptp: Change ptp_class to a proper bitmask
Date: Fri, 30 Oct 2015 21:39:25 +0100
Message-ID: <20151030203925.GE27879@netboy>
References: <1446207244-2206-1-git-send-email-stefan.sorensen@spectralink.com>
 <1446207244-2206-5-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stefan =?iso-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectralink.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:33220 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759823AbbJ3Uj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 16:39:29 -0400
Received: by wijp11 with SMTP id p11so18581101wij.0
        for <netdev@vger.kernel.org>; Fri, 30 Oct 2015 13:39:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1446207244-2206-5-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 30, 2015 at 01:14:03PM +0100, Stefan S=F8rensen wrote:
> Change the definition of PTP_CLASS_L2 to not have any bits overlappin=
g with
> the other defined protocol values, allowing the PTP_CLASS_* definitio=
ns to
> be for simple filtering on packet type.
>=20
> Signed-off-by: Stefan S=F8rensen <stefan.sorensen@spectralink.com>

Acked-by: Richard Cochran <richardcochran@gmail.com>
