From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Allow setting dev->weight using ip(8)
Date: 30 Aug 2004 08:42:20 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1093869740.1076.587.camel@jzny.localdomain>
References: <5cac192f040830035669628d1@mail.gmail.com>
	 <1093868860.1075.573.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Lemoine <eric.lemoine@gmail.com>
In-Reply-To: <1093868860.1075.573.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-08-30 at 08:27, jamal wrote:

> to do so, just curious. BTW, As Dave pointed out alwauIFLA_WEIGHT

LOL ;->
As Dave pointed out any new attributes go to the end of the enumeration.
It may not matter in this case if Dave hasnt applied Thomas' patch.
Otherwise IFLA_WEIGHT should be last.

cheers,
jamal
