From: Lucas Bates <lucasb@mojatatu.com>
Subject: Re: [PATCH net-next] tc-testing: gitignore, ignore standard python artifacts
Date: Tue, 31 Oct 2017 14:40:21 -0400
Message-ID: <CAMDBHYLfqqxUU1+DKY6yDUPP-1j6c7y_=AtzNQLtz2DOy=PFPQ@mail.gmail.com>
References: <20171031182654.9674-1-bjb@mojatatu.com>
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
Received: from mail-wm0-f50.google.com ([74.125.82.50]:53025 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932673AbdJaSkn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 14:40:43 -0400
Received: by mail-wm0-f50.google.com with SMTP id t139so765810wmt.1
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 11:40:42 -0700 (PDT)
In-Reply-To: <20171031182654.9674-1-bjb@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 31, 2017 at 2:26 PM, Brenda J. Butler <bjb@mojatatu.com> wrote:
> Ignore .pyc files, "python compiled" files, that get created
> when a python script is run.  They should never be committed.
>
> Signed-off-by: Brenda J. Butler <bjb@mojatatu.com>
Acked-by: Lucas Bates <lucasb@mojatatu.com>
