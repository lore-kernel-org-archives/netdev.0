From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v2 1/7] vxlan: avoid vlan processing in vxlan
 device.
Date: Sun, 6 Nov 2016 12:57:48 +0300
Message-ID: <353545ba-268b-5e19-caf6-f10ca64c3f94@cogentembedded.com>
References: <1478371557-71888-1-git-send-email-pshelar@ovn.org>
 <1478371557-71888-2-git-send-email-pshelar@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Pravin B Shelar <pshelar@ovn.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f44.google.com ([209.85.215.44]:35802 "EHLO
        mail-lf0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751474AbcKFJ5v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 6 Nov 2016 04:57:51 -0500
Received: by mail-lf0-f44.google.com with SMTP id b14so93084020lfg.2
        for <netdev@vger.kernel.org>; Sun, 06 Nov 2016 01:57:50 -0800 (PST)
In-Reply-To: <1478371557-71888-2-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 11/5/2016 9:45 PM, Pravin B Shelar wrote:

> VxLan device does not have special handling for vlan taging on egress.

    Tagging.

> Therefore it does not make sense to expose vlan offloading feature.
>
> Signed-off-by: Pravin B Shelar <pshelar@ovn.org>
[...]

MBR, Sergei
