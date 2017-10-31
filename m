From: Lucas Bates <lucasb@mojatatu.com>
Subject: Re: [PATCH net-next] tc-testing: "show" action shows all selected tests
Date: Tue, 31 Oct 2017 14:45:02 -0400
Message-ID: <CAMDBHYJESQWL+Koj9Wzw9MN8gcPgSvuhLD8u3Ehr2Jz3ATWeCA@mail.gmail.com>
References: <20171031183016.9981-1-bjb@mojatatu.com>
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
Received: from mail-wm0-f68.google.com ([74.125.82.68]:47923 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932685AbdJaSpY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 14:45:24 -0400
Received: by mail-wm0-f68.google.com with SMTP id r196so752236wmf.2
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 11:45:23 -0700 (PDT)
In-Reply-To: <20171031183016.9981-1-bjb@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 31, 2017 at 2:30 PM, Brenda J. Butler <bjb@mojatatu.com> wrote:
> The -s "show" option takes an argument to specify which test
> to show.  Change the option so it does not take an argument,
> but outputs all the tests that were selected with the other
> arguments.
>
> It is still possible to output a single test, by using the -e
> option, but now more than one test can be displayed with
> one command.
>
> Signed-off-by: Brenda J. Butler <bjb@mojatatu.com>
Acked-by: Lucas Bates <lucasb@mojatatu.com>
