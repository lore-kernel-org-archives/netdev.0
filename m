From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 03/10] sctp: factor out stream->in allocation
Date: Fri, 29 Sep 2017 10:04:15 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD0084F8E@AcuExch.aculab.com>
References: <cover.1506536044.git.marcelo.leitner@gmail.com>
 <a2d837095740147003164fe573794c140001ec71.1506536044.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Xin Long <lucien.xin@gmail.com>
To: 'Marcelo Ricardo Leitner' <marcelo.leitner@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.183]:64954 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750709AbdI2KEV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 06:04:21 -0400
In-Reply-To: <a2d837095740147003164fe573794c140001ec71.1506536044.git.marcelo.leitner@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner
> Sent: 28 September 2017 21:25
> Same idea as previous patch.

That needs a proper description.

	David
