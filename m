From: "Randy Macleod" <macleodr@nortel.com>
Subject: Re: [PATCH 6/6] Phonet: pipe end-point protocol documentation
Date: Wed, 01 Oct 2008 11:19:14 -0400
Message-ID: <48E394F2.2080808@nortel.com>
References: <200810011312.17288.remi.denis-courmont@nokia.com> <1222855985-22859-6-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kn.nortel.com ([47.140.192.55]:55275 "EHLO
	zrtps0kn.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753159AbYJAPjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 11:39:16 -0400
In-Reply-To: <1222855985-22859-6-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remi Denis-Courmont wrote:
> From: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
=2E..
> +WARNING:
> +When polling a connected pipe socket for writability, there is an
> +intrinsic race condition whereby writability might be lost between t=
he
> +polling and the writing system calls. In this case, the socket will
> +block until write because possible again, unless non-blocking mode i=
s
---------------------becomes
> +enabled.

// Randy
