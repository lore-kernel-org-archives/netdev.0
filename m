From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: tool to send unsolicited neighbour advertisements?
Date: Wed, 19 Jan 2011 11:33:51 -0600
Message-ID: <4D37207F.5070809@genband.com>
References: <4D35FB33.1080305@genband.com> <AANLkTi=g-tSrLMmu4JuuKrze4SJD67CSmbS3aONBw7wV@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Martin Volf <martin.volf.42@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=g-tSrLMmu4JuuKrze4SJD67CSmbS3aONBw7wV@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/19/2011 03:42 AM, Martin Volf wrote:
> On 18 January 2011 21:42, Chris Friesen <chris.friesen@genband.com> wrote:
>> We're transitioning stuff to IPv6 and I've been trying (without much
>> luck) to find a standard tool for sending out unsolicited neighbour
>> advertisements for failover purposes.
>> Is there such a thing?  In ipv4 arping works fine.
> 
> Hello,
> 
> probably http://www.remlab.net/ndisc6/

The ndisc6 tool appears to do neighbour discovery, but doesn't have any
options that I could see to send unsolicited neighbour advertisements.

There are various blackhat-type tools to do this, but I haven't been
able to find a real ipv6 replacement for arping.

Chris

-- 
Chris Friesen
Software Developer
GENBAND
chris.friesen@genband.com
www.genband.com
