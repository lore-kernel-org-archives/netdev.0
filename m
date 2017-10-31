From: Lucas Bates <lucasb@mojatatu.com>
Subject: Re: [PATCH net-next] tc-testing: correction to docstring in get_unique_item
Date: Mon, 30 Oct 2017 21:49:27 -0400
Message-ID: <CAMDBHYJfSbKR08Bd23S3uaAXd2ba85ik8qQ0manKq+pXOC-smA@mail.gmail.com>
References: <20171031003749.17928-1-bjb@mojatatu.com>
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
Received: from mail-wm0-f46.google.com ([74.125.82.46]:48273 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753247AbdJaBtt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 21:49:49 -0400
Received: by mail-wm0-f46.google.com with SMTP id p75so19377025wmg.3
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 18:49:48 -0700 (PDT)
In-Reply-To: <20171031003749.17928-1-bjb@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 30, 2017 at 8:37 PM, Brenda J. Butler <bjb@mojatatu.com> wrote:
> The docstring says the function returns a "set" but it returns
> a "list".  These are both python data types, so we should refer to
> the right one that is being returned.
>
> Signed-off-by: Brenda J. Butler <bjb@mojatatu.com>

Acked-by: Lucas Bates <lucasb@mojatatu.com>
