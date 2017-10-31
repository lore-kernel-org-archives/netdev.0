From: Lucas Bates <lucasb@mojatatu.com>
Subject: Re: [PATCH net-next] tc-testing: better test case file error reporting
Date: Tue, 31 Oct 2017 14:45:57 -0400
Message-ID: <CAMDBHY+9Yh63svNmmZsmrujgp+59d-pBN+m-iBMsCvZ4UbsFYg@mail.gmail.com>
References: <20171031182903.9885-1-bjb@mojatatu.com>
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
Received: from mail-wm0-f50.google.com ([74.125.82.50]:48269 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932535AbdJaSqS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 14:46:18 -0400
Received: by mail-wm0-f50.google.com with SMTP id p75so742870wmg.3
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 11:46:18 -0700 (PDT)
In-Reply-To: <20171031182903.9885-1-bjb@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 31, 2017 at 2:29 PM, Brenda J. Butler <bjb@mojatatu.com> wrote:
> tdc.py reads a bunch of test cases in json files.  When a json file
> cannot be parsed, tdc just exits and does not run any tests.
>
> This patch will cause tdc to print a message with the file name and
> line number, then that file will be ignored and the rest of the tests
> will be processed.
>
> Signed-off-by: Brenda J. Butler <bjb@mojatatu.com>
With great pleasure:

Acked-by: Lucas Bates <lucasb@mojatatu.com>
