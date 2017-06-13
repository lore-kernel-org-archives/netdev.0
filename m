From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 0/2] MDIO bus reset GPIO cleanups
Date: Tue, 13 Jun 2017 13:28:37 +0300
Message-ID: <eedb8398-58b7-b73e-636a-1cccc10afd98@cogentembedded.com>
References: <20170612205537.977289294@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Rob Herring <robh+dt@kernel.org>,
        Frank Rowand <frowand.list@gmail.com>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f41.google.com ([209.85.215.41]:35993 "EHLO
        mail-lf0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752622AbdFMK2i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 06:28:38 -0400
Received: by mail-lf0-f41.google.com with SMTP id o83so67109253lff.3
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 03:28:37 -0700 (PDT)
In-Reply-To: <20170612205537.977289294@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/12/2017 11:55 PM, Sergei Shtylyov wrote:

> Commit 4c5e7a2c0501 ("dt-bindings: mdio: Clarify binding document")
> declared that a MDIO reset GPIO property should have only a single GPIO
> reference/specifier, however the supporting code was left intact...
> Here's a couple of the obvious cleanups to that code:

    Apparently, I forgot how to write cover letters: the patches were against 
net-next (well, at least this could be deduced from the patches themselves).

MBR, Sergei
