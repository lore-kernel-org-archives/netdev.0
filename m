From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC PATCH net-next 0/9] netlink: strict attribute checking option
Date: Fri, 16 Oct 2015 11:40:11 +0200
Message-ID: <1444988411.2852230.411870761.15F9E4C9@webmail.messagingengine.com>
References: <cover.1444926905.git.jbenc@redhat.com>
 <87r3kv3hwv.fsf@stressinduktion.org> <20151016094951.11146959@griffin>
 <20151016.010826.1557577128395519123.davem@davemloft.net>
 <20151016100843.44c9172a@griffin>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: Jiri Benc <jbenc@redhat.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:44862 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752172AbbJPJkM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 05:40:12 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id A99BF2083A
	for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 05:40:11 -0400 (EDT)
In-Reply-To: <20151016100843.44c9172a@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, Oct 16, 2015, at 10:08, Jiri Benc wrote:
> On Fri, 16 Oct 2015 01:08:26 -0700 (PDT), David Miller wrote:
> > I think his point is that you'll be making changes to an RFC specified
> > protocol.
> 
> The RFC is only informational, it has never became an Internet
> standard (under the RFC terms). And no other OS picked it up. Keeping
> kernel uAPI documentation in IETF database sounds rather inefficient.

I would suggest you simply add a description to the rfc via the errata
process here: <https://www.rfc-editor.org/errata_report.php>

The original cover letter should be enough to post there. I am also not
sure if people do really implement this spec, at least they have a
pointer to it, then. AFAIK the IESG will look into that then and even
non-approved erratas will be listed on the rfc page.

Bye,
Hannes
