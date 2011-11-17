From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: Display closed UDP sockets on 'ss -ul'
Date: Wed, 16 Nov 2011 16:25:56 -0800
Message-ID: <20111116162556.71c71143@s6510.linuxnetplumber.net>
References: <1321370366-18832-1-git-send-email-contyk@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Petr =?UTF-8?B?xaBhYmF0YQ==?= <contyk@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50895 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753962Ab1KQAZ7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 19:25:59 -0500
In-Reply-To: <1321370366-18832-1-git-send-email-contyk@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Nov 2011 16:19:26 +0100
Petr =C5=A0abata <contyk@redhat.com> wrote:

> This patch emulates 'netstat -ul' behavior, showing 'closed'
> (state 07) UDP sockets when ss is called with '-ul' options.
> Although dirty, this seems like the least invasive way to fix
> it and shouldn't really break anything.
>=20
> Signed-off-by: Petr =C5=A0abata <contyk@redhat.com>

Applied
