From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 net-next] net: systemport: Support 64bit statistics
Date: Thu, 20 Jul 2017 08:44:06 -0700
Message-ID: <20170720084406.1ff2c446@xeon-e3>
References: <1500423520-4169-1-git-send-email-jqiaoulk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: "Jianming.qiao" <jqiaoulk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:32844 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934434AbdGTPoI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2017 11:44:08 -0400
Received: by mail-pg0-f49.google.com with SMTP id k14so16590849pgr.0
        for <netdev@vger.kernel.org>; Thu, 20 Jul 2017 08:44:08 -0700 (PDT)
In-Reply-To: <1500423520-4169-1-git-send-email-jqiaoulk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 19 Jul 2017 01:18:40 +0100
"Jianming.qiao" <jqiaoulk@gmail.com> wrote:

> Signed-off-by: Jianming.qiao <kiki-good@hotmail.com>

You may want to consider using per-cpu statistics.
