From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] iproute2: bridge: Close file with bridge monitor file
Date: Mon, 30 Sep 2013 21:11:06 -0700
Message-ID: <20130930211106.6bccd8da@nehalam.linuxnetplumber.net>
References: <1380095145-6618-1-git-send-email-ppisar@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: Petr =?UTF-8?B?UMOtc2HFmQ==?= <ppisar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:60450 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751601Ab3JAELJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 00:11:09 -0400
Received: by mail-pd0-f181.google.com with SMTP id g10so6563971pdj.26
        for <netdev@vger.kernel.org>; Mon, 30 Sep 2013 21:11:08 -0700 (PDT)
In-Reply-To: <1380095145-6618-1-git-send-email-ppisar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 25 Sep 2013 09:45:45 +0200
Petr P=C3=ADsa=C5=99 <ppisar@redhat.com> wrote:

> The `bridge monitor file FILENAME' reads dumped netlink messages from
> a file. But it forgot to close the file after using it. This patch
> fixes it.
>=20
> Signed-off-by: Petr P=C3=ADsa=C5=99 <ppisar@redhat.com>

Applied
