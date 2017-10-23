From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 1/1] ss: initialize 'fackets' member of tcpstat
 structure
Date: Mon, 23 Oct 2017 14:44:14 +0200
Message-ID: <20171023144414.50dd683a@shemminger-XPS-13-9360>
References: <1508355841-24131-1-git-send-email-mrv@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, netdev@vger.kernel.org
To: Roman Mashak <mrv@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:51872 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932093AbdJWMoX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 08:44:23 -0400
Received: by mail-wr0-f195.google.com with SMTP id j15so5082274wre.8
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 05:44:22 -0700 (PDT)
In-Reply-To: <1508355841-24131-1-git-send-email-mrv@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 Oct 2017 15:44:01 -0400
Roman Mashak <mrv@mojatatu.com> wrote:

> 'fackets' has never been initialized with kernel extracted information, thus
> never really printed.
> 
> Signed-off-by: Roman Mashak <mrv@mojatatu.com>

Applied. Thanks
