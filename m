From: Christian Schmid <webmaster@rapidforum.com>
Subject: Re: MultiPath Routing
Date: Thu, 05 May 2005 21:15:57 +0200
Message-ID: <427A70ED.3010305@rapidforum.com>
References: <E1DTfb8-0005lI-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1DTfb8-0005lI-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Did you enable IP_ROUTE_MULTIPATH_CACHED? If so please disable it
> since it breaks multipath routing for forwarded traffic.

Yes I enabled it. But it shouldnt do anything because its no forwarded traffic here. I just used 
example-IPs. Or does the bug also break non-forwarded traffic?
