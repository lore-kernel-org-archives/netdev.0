From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next RESEND] net: Do not call ndo_dflt_fdb_dump if
 ndo_fdb_dump is defined.
Date: Thu, 18 Dec 2014 17:32:56 -0500
Message-ID: <54935618.4070005@mojatatu.com>
References: <c6756bd161048ac4b4407e308045fe73.squirrel@poczta.wsisiz.edu.pl>    <54894850.5000603@cumulusnetworks.com>    <7968540cd0768a770b0c8b29ce41a162.squirrel@poczta.wsisiz.edu.pl>    <5489D53E.5010603@cumulusnetworks.com>    <8d4ec5c1ae73c77866a0a154fb528f23.squirrel@poczta.wsisiz.edu.pl>    <548AD781.5020004@mojatatu.com>    <4c22a6c452a73b3b77a9a9c8e7f76bcc.squirrel@poczta.wsisiz.edu.pl>    <548AFD41.3010801@mojatatu.com> <548B4AA4.1020804@gmail.com>    <548EF05E.6050401@mojatatu.com> <548F80B2.80408@gmail.com>    <5491A3B5.9070601@redhat.com> <e3ac4e3535a18f6dd1cf31030674f91c.squirrel@poczta.wsisiz.edu.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hubert Sokolowski <h.sokolowski@wit.edu.pl>, vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:40205 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125AbaLRWc7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2014 17:32:59 -0500
Received: by mail-ob0-f178.google.com with SMTP id gq1so6562808obb.9
        for <netdev@vger.kernel.org>; Thu, 18 Dec 2014 14:32:59 -0800 (PST)
In-Reply-To: <e3ac4e3535a18f6dd1cf31030674f91c.squirrel@poczta.wsisiz.edu.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for the latency (head-buried-in-sand in effect)

On 12/17/14 11:18, Hubert Sokolowski wrote:

> I have just prepared a patch where I dump uc/mc for bridge devices
> by looking at (dev->priv_flags & IFF_EBRIDGE), so I have same results
> as without my changes. This should satisfy Jamal and Roopa.
> I could send it as v3 of my patch along with the results if you are
> interested.
>


Please do. If you satisfy Vlad's goals then we are all happy.

cheers,
jamal
