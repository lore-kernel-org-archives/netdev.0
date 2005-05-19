From: jamal <hadi@cyberus.ca>
Subject: Re: igmp snooping?
Date: Thu, 19 May 2005 09:43:41 -0400
Message-ID: <1116510221.6240.50.camel@localhost.localdomain>
References: <20050519050958.86591.qmail@web31503.mail.mud.yahoo.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Stevens <dlstevens@us.ibm.com>,
        Lennert Buytenhek <buytenh@wantstofly.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jonathan Day <imipak@yahoo.com>
In-Reply-To: <20050519050958.86591.qmail@web31503.mail.mud.yahoo.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-18-05 at 22:09 -0700, Jonathan Day wrote:
> mentation-dependent.
> 
> Now, in 99.99% of all cases, you're not going to have
> any significant IGMPv3 traffic, as barely anyone uses
> it yet and IGMP specifies that the highest common
> version will be used in a group. 

A significant amount of video type apps that i have seen lately
try to use IGMPv3 and then fallback to IGMPv2. I think that this may be
aggravated due to our friends at MS discovering IGMPv3.

cheers,
jamal
