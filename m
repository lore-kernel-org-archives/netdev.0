From: "Eric Barton" <eeb@bartonsoftware.com>
Subject: RE: PATCH zero-copy send completion callback
Date: Tue, 17 Oct 2006 13:27:07 +0100
Message-ID: <020f01c6f1e7$8fda8500$0281a8c0@ebpc>
References: <20061017094643.GA28926@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out3.blueyonder.co.uk ([195.188.213.6]:10411 "EHLO
	smtp-out3.blueyonder.co.uk") by vger.kernel.org with ESMTP
	id S1750698AbWJQM1N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 08:27:13 -0400
To: "'Christoph Hellwig'" <hch@infradead.org>,
	"'David Miller'" <davem@davemloft.net>
In-Reply-To: <20061017094643.GA28926@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> In addition to that I'm pretty sure I remember that some clusterfs
> person already posted these patches a while ago and got ripped apart
> in the same way.

Yes - unfortunately I didn't submit my patch personally.  And I've
rewritten it since to to avoid the obvious criticisms.  This time
around, I find the comments much more to the point.

                Cheers,
                        Eric


