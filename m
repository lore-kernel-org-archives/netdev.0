From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v3] ptp: Allow selecting trigger/event index in testptp
Date: Tue, 4 Feb 2014 09:01:22 +0100
Message-ID: <20140204080120.GA4447@netboy>
References: <1391499996-10233-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stefan =?iso-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectralink.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f179.google.com ([209.85.215.179]:40114 "EHLO
	mail-ea0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751234AbaBDIBj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Feb 2014 03:01:39 -0500
Received: by mail-ea0-f179.google.com with SMTP id q10so3491266ead.24
        for <netdev@vger.kernel.org>; Tue, 04 Feb 2014 00:01:38 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1391499996-10233-1-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 04, 2014 at 08:46:36AM +0100, Stefan S=F8rensen wrote:
> Currently the trigger/event is hardcoded to 0, this patch adds
> a new command line argument -i to select an arbitrary trigger/
> event.
>=20
> Signed-off-by: Stefan S=F8rensen <stefan.sorensen@spectralink.com>
> ---
> Changes from v2:
> * Keep options sorted all places - don't submit patches before cup of=
=20
>   coffee :-)
>=20
> Changes from v1:
>  * Keep options sorted

Thanks for reworking this.

Acked-by: Richard Cochran <richardcochran@gmail.com>
