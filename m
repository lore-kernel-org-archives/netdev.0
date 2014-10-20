From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH stable v3.2 v3.4] ipv4: disable bh while doing route gc
Date: Mon, 20 Oct 2014 11:39:42 -0400 (EDT)
Message-ID: <20141020.113942.494881588483054629.davem@davemloft.net>
References: <1413774581.31953.12.camel@decadent.org.uk>
	<20141020.002308.1276148768580405795.davem@davemloft.net>
	<1413807808.31953.24.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mleitner@redhat.com, stable@vger.kernel.org,
	netdev@vger.kernel.org, hannes@stressinduktion.org
To: ben@decadent.org.uk
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1413807808.31953.24.camel@decadent.org.uk>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <ben@decadent.org.uk>
Date: Mon, 20 Oct 2014 13:23:28 +0100

> On Mon, 2014-10-20 at 00:23 -0400, David Miller wrote:
>> From: Ben Hutchings <ben@decadent.org.uk>
>> Date: Mon, 20 Oct 2014 04:09:41 +0100
>> 
>> > I've appplied this and the previous two patches mentioned ('ipv4: move
>> > route garbage collector to work queue' and 'ipv4: avoid parallel route
>> > cache gc executions').  But I didn't get the other two from you.  The
>> > last batch of networking fixes I received and applied was dated
>> > 2014-08-07, and the next one I've seen is dated 2014-10-11 and has
>> > nothing for 3.2 or 3.4.  Did I miss one between these?
>> 
>> I'm at the point where I'm personally not going to go back more than
>> four releases, anything more than that is rediculous.
>> 
>> And this time that was 3.17, 3.16, 3.14, and 3.10
> 
> OK.  I appreciate all the work you've done to backport to 3.2, but would
> also have appreciated an explicit note to say you were dropping the
> earlier versions.

My apologies, but as time goes on and more -stable releases go active
I will certainly be tail dropping to keep it within 4 releases.
