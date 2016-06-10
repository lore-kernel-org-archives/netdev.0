From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] rxrpc: Limit the listening backlog
Date: Fri, 10 Jun 2016 10:49:02 -0700 (PDT)
Message-ID: <20160610.104902.1935718349719003289.davem@davemloft.net>
References: <146556584336.17266.3323627198404452525.stgit@warthog.procyon.org.uk>
	<146556583626.17266.7208552374581913605.stgit@warthog.procyon.org.uk>
	<17686.1465566028@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <17686.1465566028@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Fri, 10 Jun 2016 14:40:28 +0100

> David Howells <dhowells@redhat.com> wrote:
> 
>> +		else if (backlog > max)
>> +			break;
> 
> Oops.  Please ignore this version of the patch - I forgot to commit a change
> to it before posting.

You also forgot to include a "0/2" introductory posting for the series
as well.
