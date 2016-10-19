From: Robin Holt <robinmholt@gmail.com>
Subject: Re: [PATCH net-next 6/6] net: use core MTU range checking in misc drivers
Date: Wed, 19 Oct 2016 09:37:22 -0500
Message-ID: <CAPp3RGrEcXcbiyaREVo=onx2oqRZvDPYHxTiS3c=v3vmg_hwCQ@mail.gmail.com>
References: <20161019023333.15760-1-jarod@redhat.com> <20161019023333.15760-7-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
        Stefan Richter <stefanr@s5r6.in-berlin.de>,
        Faisal Latif <faisal.latif@intel.com>,
        linux-rdma@vger.kernel.org, Cliff Whickman <cpw@sgi.com>,
        Jes Sorensen <jes@trained-monkey.org>,
        Marek Lindner <mareklindner@neomailbox.ch>,
        Simon Wunderlich <sw@simonwunderlich.de>,
        Antonio Quartulli <a@unstable.cc>
To: Jarod Wilson <jarod@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:36766 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S942681AbcJSOhY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 10:37:24 -0400
In-Reply-To: <20161019023333.15760-7-jarod@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 18, 2016 at 9:33 PM, Jarod Wilson <jarod@redhat.com> wrote:
> CC: netdev@vger.kernel.org
> CC: Stefan Richter <stefanr@s5r6.in-berlin.de>
> CC: Faisal Latif <faisal.latif@intel.com>
> CC: linux-rdma@vger.kernel.org
> CC: Cliff Whickman <cpw@sgi.com>

Acked-by: Robin Holt <robinmholt@gmail.com>

> CC: Jes Sorensen <jes@trained-monkey.org>
> CC: Marek Lindner <mareklindner@neomailbox.ch>
> CC: Simon Wunderlich <sw@simonwunderlich.de>
> CC: Antonio Quartulli <a@unstable.cc>
> Signed-off-by: Jarod Wilson <jarod@redhat.com>
