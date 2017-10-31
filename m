From: Lucas Bates <lucasb@mojatatu.com>
Subject: Re: [PATCH net-next] tc-testing: split config file
Date: Tue, 31 Oct 2017 14:40:44 -0400
Message-ID: <CAMDBHYKbk0SBYA4YQu98Yef+KOBBH=16evXyoHcmyVVC7bSUKw@mail.gmail.com>
References: <20171031182728.9725-1-bjb@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: davem@davemloft.net, Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>, Chris Mi <chrism@mellanox.com>,
        Alexander Aring <aring@mojatatu.com>,
        Roman Mashak <mrv@mojatatu.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: "Brenda J. Butler" <bjb@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:56082 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932806AbdJaSlF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 14:41:05 -0400
Received: by mail-wm0-f66.google.com with SMTP id y83so724135wmc.4
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 11:41:05 -0700 (PDT)
In-Reply-To: <20171031182728.9725-1-bjb@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 31, 2017 at 2:27 PM, Brenda J. Butler <bjb@mojatatu.com> wrote:
> Move the config customization into a site-local file
> tdc_config_local.py, so that updates of the tdc test
> software does not require hand-editing of the config.
> This patch includes a template for the site-local
> customization file.
>
> In addition, this makes it easy to revert to a stock
> tdc environment for testing the test framework and/or
> the core tests.
>
> Also it makes it harder for any custom config to be
> submitted back to the kernel tdc.
>
> Signed-off-by: Brenda J. Butler <bjb@mojatatu.com>
Acked-by: Lucas Bates <lucasb@mojatatu.com>
