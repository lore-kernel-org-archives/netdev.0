From: Sunil Kovvuri <sunil.kovvuri@gmail.com>
Subject: Re: [PATCH 3/5] net: thunderx: Fix configuration of L3/L4 length checking
Date: Mon, 14 Nov 2016 22:56:12 +0530
Message-ID: <CA+sq2CfTTvFbkBaLW5sHt1CHr0DjwyV12aho5hHYbvkDiR_ZCQ@mail.gmail.com>
References: <1479120886-13425-1-git-send-email-sunil.kovvuri@gmail.com>
 <1479120886-13425-4-git-send-email-sunil.kovvuri@gmail.com> <20161114123350.GA2449@Red>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Sunil Goutham <sgoutham@cavium.com>,
        LKML <linux-kernel@vger.kernel.org>,
        LAKML <linux-arm-kernel@lists.infradead.org>
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:37455 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754867AbcKNR0P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 12:26:15 -0500
In-Reply-To: <20161114123350.GA2449@Red>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>You could use the BIT() macro here
Thanks, will change and resubmit.

Sunil.
