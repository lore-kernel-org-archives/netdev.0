From: "David S. Miller" <davem@redhat.com>
Subject: Re: O/M flags against 2.6.0-test1
Date: Thu, 11 Sep 2003 19:25:07 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030911192507.0b3f2633.davem@redhat.com>
References: <20030730220223.4c25fcfe.davem@redhat.com>
	<Pine.LNX.4.44.0307311330200.27478-100000@DYN318430>
	<20030804165746.133f370a.davem@redhat.com>
	<3F58D567.2050201@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, netdev@oss.sgi.com,
   krkumar@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krishna Kumar <krkumar@us.ibm.com>
In-Reply-To: <3F58D567.2050201@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 05 Sep 2003 11:26:47 -0700
Krishna Kumar <krkumar@us.ibm.com> wrote:

>  > Otherwise I am OK with the patch.
> 
> OK, should I fix these two bugs and re-submit against test4 kernel ?
> 
> Dave, I would like to get the prefix list and O/M flags information included
> in 2.4 kernel too, are you OK with that ?

Yes, rebuild the patch against current 2.6.x and yes I'm happy
to apply a 2.4.x version as well.

Also, thank you for explaining how the message embedding works.
