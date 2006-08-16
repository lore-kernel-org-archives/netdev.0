From: John Haller <jhaller@lucent.com>
Subject: Re: New driver questions: Attansic L1 gigabit NIC
Date: Wed, 16 Aug 2006 13:44:43 -0500
Message-ID: <44E3679B.4030603@lucent.com>
References: <44DFBFBE.1070201@bellsouth.net>	<20060815143457.5fde176b@dxpl.pdx.osdl.net>	<44E25767.6010208@bellsouth.net> <20060816110501.0d7502a8@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jay Cliburn <jacliburn@bellsouth.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ihemail3.lucent.com ([135.245.0.37]:37629 "EHLO
	ihemail3.lucent.com") by vger.kernel.org with ESMTP
	id S1750756AbWHPSox (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 14:44:53 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060816110501.0d7502a8@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Tue, 15 Aug 2006 18:23:19 -0500
> Jay Cliburn <jacliburn@bellsouth.net> wrote:
> 
>> Stephen Hemminger wrote:
>>> On Sun, 13 Aug 2006 19:11:42 -0500
>>> Jay Cliburn <jacliburn@bellsouth.net> wrote:
>> ...snip...
>>>> I've read the LKML FAQ regarding new driver submissions, but it implies
>>>> that the submitter be willing to maintain the driver, which I'm not
>>>> qualified to do.  I haven't contacted Attansic to request a change to
>>>> the above support statement, because my past attempts to contact vendors
>>>> on matters of this tenor have been greeted with silence.
>>> I would recommend the module author to see if they would GPL it.
>> Thank you for your reply.  I've contacted the author as you suggest.
>>
> 
> IANAL but because they used GPL code in the driver, one could argue
> that they created a derived work covered by GPL already. But I learned in
> preschool it is always better to ask than take.
Not exactly.  What they wrote is covered by their copyright,
and there is no permission to use it in any way other than
how they licensed it.  Use of GPL code in their driver
would allow the author of the GPL code to sue them for
violating the license agreement, which would likely result
in the code being released under GPL.

IANAL either, but to paraphrase another preschool saying,
two wrongs (copyright violations) don't make a right
(legally licensed).
