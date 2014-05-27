From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: Revert 462fb2af9788a82a534f8184abfde31574e1cfa0 (bridge :
 Sanitize skb before it enters the IP stack)
Date: Tue, 27 May 2014 08:55:12 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1724E207@AcuExch.aculab.com>
References: <537CF5A2.3080401@pandora.be>
	<20140521.161841.1806439174351824310.davem@davemloft.net>
	<53803488.6000400@davidnewall.com>
 <20140524.134356.992924324126016022.davem@davemloft.net>
 <53815623.8020506@davidnewall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "bdschuym@pandora.be" <bdschuym@pandora.be>,
	"fw@strlen.de" <fw@strlen.de>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	"bsd@redhat.com" <bsd@redhat.com>,
	"vyasevich@gmail.com" <vyasevich@gmail.com>
To: 'David Newall' <davidn@davidnewall.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:49197 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751736AbaE0I4I convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 04:56:08 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 17682-01 for <netdev@vger.kernel.org>;
 Tue, 27 May 2014 09:55:58 +0100 (BST)
In-Reply-To: <53815623.8020506@davidnewall.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Newall
> On 25/05/14 03:13, David Miller wrote:
> > This patch was substantially corrupted by your email client.
> 
> We should be sending these things as mime attachments.  Having to put
> patches inline is brittle, absurd and a waste of everyone's time.  Is
> there actually anybody here who doesn't have a mime-compatible MUA?

Yes - anyone using the email client from the world's largest desktop
computer software company.

It doesn't have any method for displaying text attachments.
It has a scheme for executing attachments, for which it will use
an interpreter based on the filename extension.
(Yes - this is why it is very good at propagating viruses.)

FWIW it can send valid patches quite easily - just copy/paste from wordpad.
(Possibly after hacking the registry to allow lines longer than 72 characters.

	David
