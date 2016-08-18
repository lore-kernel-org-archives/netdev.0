From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 1/1] tc classifiers: Modernize tcindex
 classifier
Date: Thu, 18 Aug 2016 14:57:41 -0700
Message-ID: <20160818145741.2a6394f3@xeon-e3>
References: <1471432613-13459-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36797 "EHLO
        mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753806AbcHSDa0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 23:30:26 -0400
Received: by mail-pa0-f52.google.com with SMTP id pp5so11722825pac.3
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 20:30:26 -0700 (PDT)
In-Reply-To: <1471432613-13459-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 17 Aug 2016 07:16:53 -0400
Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
> ---

The is ok for the parsing of config, but you are still using print_police
for display.
