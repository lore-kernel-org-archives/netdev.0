From: Richard Siegfried <richard_siegfried@systemli.org>
Subject: Re: [PATCH net-next 0/3] A own subdirectory for shared TCP code
Date: Wed, 4 Oct 2017 20:54:17 +0200
Message-ID: <d7237d11-ec83-0ef6-d201-da8b99c94b88@systemli.org>
References: <20171003222213.7996-1-richard_siegfried@systemli.org>
 <20171003.160338.1370433279322133749.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.systemli.org ([198.167.223.214]:46016 "EHLO
        mail.systemli.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751066AbdJDSyU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 14:54:20 -0400
In-Reply-To: <20171003.160338.1370433279322133749.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/10/17 01:03, David Miller wrote:
> As someone who has to do backports regularly to -stable, there is no way
> I am applying this.
> 
> Sorry.
Okay, I see.

Is grouping files into subdirectories something generally
unwanted/unlikely to be applied or is this specific to TCP / networking?

Because there are several other places in the source tree where I would
like to group things.
