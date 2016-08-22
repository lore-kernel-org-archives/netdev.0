From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH iproute2 1/1] tc classifiers: Modernize tcindex classifier
Date: Mon, 22 Aug 2016 07:12:38 -0400
Message-ID: <2f0e5d21-786f-b34c-7f8d-b8f847624f67@mojatatu.com>
References: <1471432613-13459-1-git-send-email-jhs@emojatatu.com>
 <20160818145741.2a6394f3@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:35344 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752098AbcHVLMl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 07:12:41 -0400
Received: by mail-io0-f170.google.com with SMTP id m101so106258775ioi.2
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 04:12:40 -0700 (PDT)
In-Reply-To: <20160818145741.2a6394f3@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-18 05:57 PM, Stephen Hemminger wrote:

> The is ok for the parsing of config, but you are still using print_police
> for display.

Thanks for catching that. I will send a v2.

cheers,
jamal
