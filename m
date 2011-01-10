From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [patch] phonet: some signedness bugs
Date: Mon, 10 Jan 2011 16:08:43 +0200
Message-ID: <201101101608.44403.remi.denis-courmont@nokia.com>
References: <20110107203755.GB1959@bicker> <201101100958.32549.remi.denis-courmont@nokia.com> <20110110140141.GA2721@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, dan.j.rosenberg@gmail.com
To: ext Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw-da01.ext.nokia.com ([147.243.128.24]:59440 "EHLO
	mgw-da01.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754086Ab1AJOIf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 09:08:35 -0500
In-Reply-To: <20110110140141.GA2721@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 10 January 2011 16:01:41 ext Dan Carpenter, you wrote:
> I would like to keep the change to phonet_proto_register() because th=
e
> check in there isn't right and it's similar to phonet_proto_get().   =
We
> may as well keep phonet_proto_unregister() as well so it's symmetric.
> Let me know if you disagree and I'll redo it.

Sounds sensible to me.

--=20
R=E9mi Denis-Courmont
Nokia Devices R&D, Maemo Software, Helsinki
