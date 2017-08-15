From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH 14/51] ipvrf: Don't try to close an invalid fd
Date: Tue, 15 Aug 2017 08:14:24 -0700
Message-ID: <20170815081424.1df4effa@xeon-e3>
References: <20170812120510.28750-1-phil@nwl.cc>
        <20170812120510.28750-15-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:38435 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752233AbdHOPO0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 11:14:26 -0400
Received: by mail-pg0-f42.google.com with SMTP id l64so7286823pge.5
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 08:14:26 -0700 (PDT)
In-Reply-To: <20170812120510.28750-15-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 12 Aug 2017 14:04:33 +0200
Phil Sutter <phil@nwl.cc> wrote:

> Signed-off-by: Phil Sutter <phil@nwl.cc>

close of -1 is a harmless.
