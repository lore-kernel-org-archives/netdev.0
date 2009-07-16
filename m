From: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Subject: Re: [PATCH 2/8] ar9170: Remove unused DECLARE_MAC_BUF
Date: Thu, 16 Jul 2009 09:39:15 -0700
Message-ID: <43e72e890907160939m1b1a90c5ye1a1d27be1843714@mail.gmail.com>
References: <1247734381-20718-1-git-send-email-klto@zhaw.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: chunkeey@web.de, linville@tuxdriver.com, johannes@sipsolutions.net,
	yi.zhu@intel.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Tobias Klauser <klto@zhaw.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:46701 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932549AbZGPQjg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 12:39:36 -0400
In-Reply-To: <1247734381-20718-1-git-send-email-klto@zhaw.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 16, 2009 at 1:53 AM, Tobias Klauser<klto@zhaw.ch> wrote:
> Is not needed anymore because of the %pM printk conversion specifier.
>
> Signed-off-by: Tobias Klauser <klto@zhaw.ch>
> ---
> =C2=A0drivers/net/wireless/ath/ar9170/main.c | =C2=A0 =C2=A01 -
> =C2=A01 files changed, 0 insertions(+), 1 deletions(-)

This is already patched by Johannes through the patch titled:

[PATCH] wireless: remove print_mac uses

Please see and resubmit if there is anything missing:

http://marc.info/?l=3Dlinux-wireless&m=3D124767211929848&w=3D2

 Luis
