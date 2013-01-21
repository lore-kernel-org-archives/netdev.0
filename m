From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: IPsec AH use of ahash
Date: Mon, 21 Jan 2013 09:49:19 -0600
Message-ID: <50FD637F.2080604@genband.com>
References: <1161725580.95543.1358782288077.JavaMail.root@elliptictech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Steven Rostedt <rostedt@goodmis.org>,
	David Dillow <dave@thedillows.org>,
	Borislav Petkov <bp@alien8.de>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Tom St Denis <tstdenis@elliptictech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og102.obsmtp.com ([64.18.2.157]:59779 "EHLO
	exprod7og102.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752961Ab3AUPuH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 10:50:07 -0500
In-Reply-To: <1161725580.95543.1358782288077.JavaMail.root@elliptictech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/21/2013 09:31 AM, Tom St Denis wrote:
> ----- Original Message -----
>> From: "Steven Rostedt"<rostedt@goodmis.org> To: "Tom St
>> Denis"<tstdenis@elliptictech.com> Cc: "David
>> Dillow"<dave@thedillows.org>, "Borislav Petkov"<bp@alien8.de>,
>> linux-kernel@vger.kernel.org, netdev@vger.kernel.org Sent: Monday,
>> 21 January, 2013 10:28:33 AM Subject: Re: IPsec AH use of ahash
>>
>> When I send a patch to another maintainer, and they tell me to fix
>> the way I did the comments, I don't complain. I fix the comments
>> and resend.
>
> Which is less of a problem when there is a timeliness factor.  In the
> business world people move on and don't work at that pace.

There can be an impedance mismatch between the "get it done to hit a 
deadline" business world and the "get it right no matter how long it 
takes" world of some open-source projects.

However, many businesses have recognized that they get far more benefit 
from dealing with open-source than it costs them in designer time.

 From the point of view of my employer (I work in telecom) the choices 
are either:

a) work with the kernel to get the code submitted into mainline
b) keep the changes private and port them every time we upgrade

Over a decade or more my management has come to realize that option "a" 
is generally better in the long term, even if it's a bit more effort in 
the short term.

There are exceptions of course, and sometimes we just need to do a 
quick-and-dirty solution to get something out the door.

Chris
