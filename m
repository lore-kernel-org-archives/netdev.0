From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [next-queue PATCH v2 3/5] net/sched: Introduce the user API for
 the CBS shaper
Date: Sat, 30 Sep 2017 17:24:11 -0700
Message-ID: <CAM_iQpWGHE7hgwEZDO+oRGgWdrdYYofnHfuQq3fMOO-yFj7NSw@mail.gmail.com>
References: <20170930002657.15291-1-vinicius.gomes@intel.com> <20170930002657.15291-4-vinicius.gomes@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>, andre.guedes@intel.com,
        Ivan Briano <ivan.briano@intel.com>,
        Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>,
        boon.leong.ong@intel.com, richardcochran@gmail.com,
        Henrik Austad <henrik@austad.us>, levipearson@gmail.com,
        rodney.cummings@ni.com
To: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:43511 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750988AbdJAAYc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2017 20:24:32 -0400
Received: by mail-pf0-f179.google.com with SMTP id y29so1390603pff.0
        for <netdev@vger.kernel.org>; Sat, 30 Sep 2017 17:24:32 -0700 (PDT)
In-Reply-To: <20170930002657.15291-4-vinicius.gomes@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 29, 2017 at 5:26 PM, Vinicius Costa Gomes
<vinicius.gomes@intel.com> wrote:
> Export the API necessary for configuring the CBS shaper (implemented
> in the next patch) via the tc tool.

This one can be folded into patch 4/5.
