From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [ethtool PATCH v2 06/12] test-common.c: fix test_realloc(NULL, ...)
Date: Fri, 4 Mar 2016 05:32:01 -0800
Message-ID: <CAHo-OoxARqLmJTcV1p+Ub5fBcCXUwHHj3XR2g6QUDkShN3-EKQ@mail.gmail.com>
References: <1457065405-19049-1-git-send-email-ddecotig@gmail.com>
	<1457065405-19049-7-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux NetDev <netdev@vger.kernel.org>,
	Jeff Garzik <jgarzik@pobox.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	David Decotigny <decot@googlers.com>
To: David Decotigny <ddecotig@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f196.google.com ([209.85.217.196]:34959 "EHLO
	mail-lb0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751399AbcCDNcC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 08:32:02 -0500
Received: by mail-lb0-f196.google.com with SMTP id h2so4932107lbs.2
        for <netdev@vger.kernel.org>; Fri, 04 Mar 2016 05:32:02 -0800 (PST)
In-Reply-To: <1457065405-19049-7-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If needed:

Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
