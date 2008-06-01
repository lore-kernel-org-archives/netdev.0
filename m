From: "Avuton Olrich" <avuton@gmail.com>
Subject: Re: atl1 card hibernation regression
Date: Sun, 1 Jun 2008 15:57:07 -0700
Message-ID: <3aa654a40806011557u2007745dw212a83882a93f837@mail.gmail.com>
References: <3aa654a40806010742s7529b9fxe02d0204f329065b@mail.gmail.com>
	 <20080601134120.3eb6651a@osprey.hogchain.net>
	 <3aa654a40806011326o2cfddfa0o6bc743041b5df8d6@mail.gmail.com>
	 <20080601164954.102d0fa1@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jgarzik@redhat.com>, netdev@vger.kernel.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: "Jay Cliburn" <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.29]:37860 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751908AbYFAW5N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2008 18:57:13 -0400
Received: by yw-out-2324.google.com with SMTP id 9so359391ywe.1
        for <netdev@vger.kernel.org>; Sun, 01 Jun 2008 15:57:12 -0700 (PDT)
In-Reply-To: <20080601164954.102d0fa1@osprey.hogchain.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 1, 2008 at 2:49 PM, Jay Cliburn <jacliburn@bellsouth.net> wrote:
> On Sun, 1 Jun 2008 13:26:26 -0700
> "Avuton Olrich" <avuton@gmail.com> wrote:
>
>> On Sun, Jun 1, 2008 at 11:41 AM, Jay Cliburn
>> <jacliburn@bellsouth.net> wrote:
>> > On Sun, 1 Jun 2008 07:42:02 -0700
>> > "Avuton Olrich" <avuton@gmail.com> wrote:
>> >
>> >> After resuming from hibernate, my network card refuses to get back
>> >> online. The bisection and much more information are below.
>> >
>> > Can you please try this patch?
> [...]
>>
>> Brilliant! Works as advertised, thanks for the quick fix!
>
> Thank you for the very thorough bug report.
>
> May I include you in the Tested-by line?
>
> Jay

Sure, thanks.
-- 
avuton
--
 "I've got a fever. And the only prescription is more cowbell." --
Christopher Walken
