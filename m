From: Kumar SANGHVI <kumar.sanghvi@stericsson.com>
Subject: Re: [PATCH 2/4] Phonet: advise against enabling the pipe controller
Date: Mon, 11 Oct 2010 12:19:05 +0530
Message-ID: <20101011064904.GA31124@bnru01.bnr.st.com>
References: <1286546523-3340-1-git-send-email-remi@remlab.net>
 <1286546523-3340-2-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	=?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont <remi@remlab.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:41154 "EHLO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752147Ab0JKGtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 02:49:18 -0400
Content-Disposition: inline
In-Reply-To: <1286546523-3340-2-git-send-email-remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, Oct 08, 2010 at 16:02:01 +0200, R=E9mi Denis-Courmont wrote:
> From: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
>=20
> As it currently is, the new code path is not compatible with existing
> Nokia modems. This would break existing userspace for Nokia modem, su=
ch
> as the existing oFono ISI driver.
>=20
> Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Yes, the pipe controller logic is not intended for existing Nokia modem=
s
that already implement pipe controller inside them.
Thank you for putting correct warning message.
