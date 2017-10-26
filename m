From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 0/3] liquidio: Switchdev support for LiquidIO NIC
Date: Thu, 26 Oct 2017 08:19:32 +0200
Message-ID: <20171026061932.GB1928@nanopsycho.orion>
References: <20171026053641.GA17861@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        raghu.vatsavayi@cavium.com, derek.chickles@cavium.com,
        satananda.burla@cavium.com, vijaya.guvva@cavium.com
To: Felix Manlunas <felix.manlunas@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:53870 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750884AbdJZGTe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 02:19:34 -0400
Received: by mail-wm0-f45.google.com with SMTP id r196so5890902wmf.2
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 23:19:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171026053641.GA17861@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Oct 26, 2017 at 07:36:41AM CEST, felix.manlunas@cavium.com wrote:
>From: Vijaya Mohan Guvva <vijaya.guvva@cavium.com>
>
>patch1 of this patch set adds switchdev support for SRIOV capable
>LiquidIO NIC, so that for every SRIOV VF on LiquidIO, a representor
>netdev is created on hyperviser. It also has changes to send representor
>interface configurations like admin state and MTU to LiquidIO firmware and
>to retrieve HW counted VF stats for VF representor.
>
>patch2 adds support for switchdev enable/disable from devlink
>
>patch3 adds ethtool support for vf representor interface to return
>VF representor port stats and driver info.

Looks fine to me.
