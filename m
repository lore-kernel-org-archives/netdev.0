From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] netconsole: implement ipv4 tos support
Date: Wed, 30 Nov 2011 17:34:35 -0800
Message-ID: <20111130173435.5e63afda@nehalam.linuxnetplumber.net>
References: <1322702330-31325-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Maciej =?UTF-8?B?xbtlbmN6eWtvd3NraQ==?= <maze@google.com>,
	netdev@vger.kernel.org
To: Maciej =?UTF-8?B?xbtlbmN6eWtvd3NraQ==?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46641 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752283Ab1LABei convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 20:34:38 -0500
In-Reply-To: <1322702330-31325-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Nov 2011 17:18:50 -0800
Maciej =C5=BBenczykowski <zenczykowski@gmail.com> wrote:

> From: Maciej =C5=BBenczykowski <maze@google.com>
>=20
> Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>

Why make it an option? TOS should always be set to interactive
traffic (like telnet and slogin)
