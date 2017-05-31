From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] devlink: Add option to set and show eswitch
 encapsulation support
Date: Tue, 30 May 2017 17:37:40 -0700
Message-ID: <20170530173740.611e93e8@xeon-e3>
References: <1495345047-55019-1-git-send-email-roid@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Paul Blakey <paulb@mellanox.com>,
        Shahar Klein <shahark@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>
To: Roi Dayan <roid@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:36770 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750902AbdEaAho (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 20:37:44 -0400
Received: by mail-pf0-f182.google.com with SMTP id m17so1810866pfg.3
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 17:37:43 -0700 (PDT)
In-Reply-To: <1495345047-55019-1-git-send-email-roid@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 21 May 2017 08:37:27 +0300
Roi Dayan <roid@mellanox.com> wrote:

> This is an e-switch global knob to enable HW support for applying
> encapsulation/decapsulation to VF traffic as part of SRIOV e-switch offloading.
> 
> The actual encap/decap is carried out (along with the matching and other
> actions) per offloaded e-switch rules, e.g as done when offloading the TC tunnel
> key action.
> 
> Possible values are enable/disable.
> 
> Signed-off-by: Roi Dayan <roid@mellanox.com>
> Reviewed-by: Jiri Pirko <jiri@mellanox.com>

Applied, thanks
