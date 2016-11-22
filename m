From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v3] net/phy: add trace events for mdio accesses
Date: Tue, 22 Nov 2016 10:58:17 -0500
Message-ID: <20161122105817.7df669a4@gandalf.local.home>
References: <20161122100127.5940-1-uwe@kleine-koenig.org>
        <20161122154711.26622-1-uwe@kleine-koenig.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Ingo Molnar <mingo@redhat.com>, netdev@vger.kernel.org
To: Uwe =?UTF-8?B?S2xlaW5lLUvDtm5pZw==?= <uwe@kleine-koenig.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0125.hostedemail.com ([216.40.44.125]:54853 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753149AbcKVP6U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 10:58:20 -0500
In-Reply-To: <20161122154711.26622-1-uwe@kleine-koenig.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Nov 2016 16:47:11 +0100
Uwe Kleine-König <uwe@kleine-koenig.org> wrote:

> Make it possible to generate trace events for mdio read and write accesses.
> 
> Signed-off-by: Uwe Kleine-König <uwe@kleine-koenig.org>

For the tracing side.

Acked-by: Steven Rostedt <rostedt@goodmis.org>

-- Steve
