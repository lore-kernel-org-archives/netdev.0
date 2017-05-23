From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 0/5] add tcp flags match support to flower and
 offload it
Date: Tue, 23 May 2017 17:11:20 +0200
Message-ID: <20170523151120.GH1829@nanopsycho>
References: <20170523143110.5006-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        simon.horman@netronome.com, mlxsw@mellanox.com, idosch@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:36749 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1764371AbdEWPLW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 11:11:22 -0400
Received: by mail-wm0-f53.google.com with SMTP id 7so28269564wmo.1
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 08:11:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170523143110.5006-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, May 23, 2017 at 04:31:05PM CEST, jiri@resnulli.us wrote:
>From: Jiri Pirko <jiri@mellanox.com>
>
>This patch adds support to dissect tcp flags, match on them using
>flower classifier and offload such rules to mlxsw Spectrum devices.

I shifted the git format patch one commit. Will send v2. Sorry.
