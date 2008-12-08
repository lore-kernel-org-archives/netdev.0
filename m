From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH net] Phonet: hold GPRS device while cleaning up
Date: Mon, 8 Dec 2008 13:03:55 +0200
Message-ID: <200812081303.55322.remi.denis-courmont@nokia.com>
References: <1228730965-19087-1-git-send-email-remi.denis-courmont@nokia.com> <20081208.022153.93642210.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "ext David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:28094 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751427AbYLHLEJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2008 06:04:09 -0500
In-Reply-To: <20081208.022153.93642210.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 08 December 2008 12:21:53 ext David Miller, you wrote:
> Can we get the phonet stack using more sensible local
> variable names for netdev pointers?

Sure. Should I send a large cosmetic s/net/dev/ et al patch against net=
-next?

--=20
R=E9mi Denis-Courmont
Maemo Software, Nokia Devices R&D
