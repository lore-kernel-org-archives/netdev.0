From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [RFC net-next 0/5] TSN: Add qdisc-based config interfaces for
 traffic shapers
Date: Wed, 20 Sep 2017 07:58:29 +0200
Message-ID: <20170920055829.bhwn6pd332ldjkeg@localhost>
References: <20170901012625.14838-1-vinicius.gomes@intel.com>
 <20170918080214.yrejz67wwnp2pjzf@localhost>
 <87k20vip3f.fsf@intel.com>
 <20170919052244.77umdxuze53t6j22@localhost>
 <87wp4ufchl.fsf@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, intel-wired-lan@lists.osuosl.org,
        andre.guedes@intel.com, ivan.briano@intel.com,
        jesus.sanchez-palencia@intel.com, boon.leong.ong@intel.com
To: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:46792 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751468AbdITF6d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 01:58:33 -0400
Received: by mail-wm0-f45.google.com with SMTP id i189so3998210wmf.1
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 22:58:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <87wp4ufchl.fsf@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 19, 2017 at 05:19:18PM -0700, Vinicius Costa Gomes wrote:
> (I think LaunchTime is something specific to the i210, right?)

Levi just told us:

   Recent SoCs from NXP (the i.MX 6 SoloX, and all the i.MX 7 and 8
   parts) support Qav shaping as well as scheduled launch
   functionality;

Thanks,
Richard
