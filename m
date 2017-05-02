From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH] flower: check unused bits in MPLS fields
Date: Mon, 1 May 2017 21:37:00 -0400
Message-ID: <af1de251-299e-a037-f4b1-21cb22051bf9@mojatatu.com>
References: <1493647120-17406-1-git-send-email-benjamin.lahaise@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Simon Horman <simon.horman@netronome.com>,
        Jakub Kicinski <kubakici@wp.pl>, Jiri Pirko <jiri@resnulli.us>
To: Benjamin LaHaise <benjamin.lahaise@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f47.google.com ([209.85.214.47]:35860 "EHLO
        mail-it0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750788AbdEBBhC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 21:37:02 -0400
Received: by mail-it0-f47.google.com with SMTP id r185so40648623itd.1
        for <netdev@vger.kernel.org>; Mon, 01 May 2017 18:37:02 -0700 (PDT)
In-Reply-To: <1493647120-17406-1-git-send-email-benjamin.lahaise@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-05-01 09:58 AM, Benjamin LaHaise wrote:
> Since several of the the netlink attributes used to configure the flower
> classifier's MPLS TC, BOS and Label fields have additional bits which are
> unused, check those bits to ensure that they are actually 0 as suggested
> by Jamal.
>
> Signed-off-by: Benjamin LaHaise <benjamin.lahaise@netronome.com>
> Cc: David Miller <davem@davemloft.net>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: Simon Horman <simon.horman@netronome.com>
> Cc: Jakub Kicinski <kubakici@wp.pl>
> Cc: Jiri Pirko <jiri@resnulli.us>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
