From: Karsten Keil <isdn@linux-pingi.de>
Subject: Re: [RFC PATCH 10/19] pcmcia: dev_node removal (drivers with updated printk call)
Date: Mon, 22 Mar 2010 06:22:28 +0100
Message-ID: <201003220622.28507.isdn@linux-pingi.de>
References: <20100321230617.GA24791@comet.dominikbrodowski.net> <1269212857-25364-10-git-send-email-linux@dominikbrodowski.net>
Reply-To: isdn@linux-pingi.de
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-pcmcia@lists.infradead.org,
	Harald Welte <laforge@gnumonks.org>, linux-ide@vger.kernel.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Dominik Brodowski <linux@dominikbrodowski.net>
Return-path: <linux-ide-owner@vger.kernel.org>
In-Reply-To: <1269212857-25364-10-git-send-email-linux@dominikbrodowski.net>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Montag, 22. M=E4rz 2010 00:07:28 Dominik Brodowski wrote:
> As a second step, remove any usage of dev_node_t from drivers which
> only wrote to this typedef/struct, except one printk() which can
> easily be replaced by a dev_info()/dev_warn() call.
>=20
> CC: Harald Welte <laforge@gnumonks.org>
> CC: linux-ide@vger.kernel.org
> CC: Karsten Keil <isdn@linux-pingi.de>
> CC: linux-wireless@vger.kernel.org
> CC: netdev@vger.kernel.org
> CC: linux-usb@vger.kernel.org
> Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>

Acked-by: Karsten Keil  <isdn@linux-pingi.de>

Thanks.
