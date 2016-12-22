From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] ip: vfinfo: remove code duplication for
 IFLA_VF_RSS_QUERY_EN
Date: Wed, 21 Dec 2016 16:05:03 -0800
Message-ID: <20161221160503.214fd5b0@xeon-e3>
References: <20161216163605.19728-1-julien@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, phil@nwl.cc
To: Julien Fortin <julien@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:34813 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760107AbcLVAFL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 19:05:11 -0500
Received: by mail-pg0-f43.google.com with SMTP id y62so38440519pgy.1
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2016 16:05:11 -0800 (PST)
In-Reply-To: <20161216163605.19728-1-julien@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 16 Dec 2016 17:36:05 +0100
Julien Fortin <julien@cumulusnetworks.com> wrote:

> From: Julien Fortin <julien@cumulusnetworks.com>
>=20
> Fixes: 4fb4a10e120b1 ("ipaddress: Print IFLA_VF_QUERY_RSS_EN setting=E2=
=80=9D)
>=20
> Signed-off-by: Julien Fortin <julien@cumulusnetworks.com>

Applied, thanks.
