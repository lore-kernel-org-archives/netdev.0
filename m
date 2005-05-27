From: jamal <hadi@cyberus.ca>
Subject: Re: PATCH: rtnetlink explicit flags setting
Date: Fri, 27 May 2005 11:57:46 -0400
Message-ID: <1117209466.6383.106.camel@localhost.localdomain>
References: <1117197157.6688.24.camel@localhost.localdomain>
	 <20050527125010.GO15391@postel.suug.ch>
	 <1117202331.6383.39.camel@localhost.localdomain>
	 <20050527141320.GQ15391@postel.suug.ch>
	 <1117206091.6383.73.camel@localhost.localdomain>
	 <20050527151913.GA15391@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050527151913.GA15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-27-05 at 17:19 +0200, Thomas Graf wrote:

> Sure, I can come up with a patchset today which will include:
>  o the new NLMSG_NEW macro
>  o your patch adopted to use the new NLMSG_NEW macro
>  o small patch to rename NLMSG_PUT_ANSWER usages into NLMSG_NEW_ANSWER
>  o a small fallout from the new neighbour table code which gcc didn't
>    warn me about when it should.
> 
> OK?

Sounds reasonable.

cheers,
jamal

PS:- Have to disappear for a few hours so they maybe latency in further
responses.
