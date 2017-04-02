From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 10/13] ftgmac100: Add a reset task and use it for link
 changes
Date: Mon, 03 Apr 2017 07:24:18 +1000
Message-ID: <1491168258.26047.18.camel@kernel.crashing.org>
References: <20170402033523.9482-1-benh@kernel.crashing.org>
         <20170402033523.9482-11-benh@kernel.crashing.org>
         <20170402184237.GB5189@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:36247 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751480AbdDBVYh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 2 Apr 2017 17:24:37 -0400
In-Reply-To: <20170402184237.GB5189@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-04-02 at 20:42 +0200, Andrew Lunn wrote:

> Have you run lockdep tests on this?

Good idea. For some reason I run it regularly on powerpc but it never
occurred to me to try it on that 800Mhz ARM11 :-)

Cheers,
Ben.
