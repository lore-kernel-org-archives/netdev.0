From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: Re: Re: [PATCH 18/23 v3] mlx4_core: Managing common port
Date: Wed, 17 Feb 2010 14:19:03 +0200
Message-ID: <15ddcffd1002170419h2b32c044r1bdb40ed4f5753c2@mail.gmail.com>
References: <4B7ABBE6.1010506@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Roland Dreier <rdreier@cisco.com>, netdev@vger.kernel.org,
	tziporet@mellanox.co.il, liranl@mellanox.co.il
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:43877 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757160Ab0BQMTF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 07:19:05 -0500
Received: by bwz19 with SMTP id 19so5409499bwz.28
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2010 04:19:04 -0800 (PST)
In-Reply-To: <4B7ABBE6.1010506@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yevgeny Petrilin <yevgenyp@mellanox.co.il> wrote:

> HW filtering, the SW configures the filter.

I understand that at some point you plan to move to HW filter, so
maybe to rephrase the
question: is this patch set applicable without the HW filter in place?
if yes, I understood you
were planning on software filtering and wondered in what level its
expected to happen.

Or.
