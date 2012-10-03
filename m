From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: List interfaces without net address by
 default
Date: Wed, 3 Oct 2012 08:57:15 -0700
Message-ID: <20121003085715.4b93c29e@nehalam.linuxnetplumber.net>
References: <1348565799-20080-1-git-send-email-ppisar@redhat.com>
	<1349275361-9271-1-git-send-email-ppisar@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: Petr =?UTF-8?B?UMOtc2HFmQ==?= <ppisar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56816 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932472Ab2JCP54 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 11:57:56 -0400
In-Reply-To: <1349275361-9271-1-git-send-email-ppisar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  3 Oct 2012 16:42:41 +0200
Petr P=C3=ADsa=C5=99 <ppisar@redhat.com> wrote:

> This fixes regression in iproute2-3.5.1 when `ip addr show' skipped
> interfaces without network layer address.
>=20

Applied
