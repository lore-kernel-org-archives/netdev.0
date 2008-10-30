From: Ferenc Wagner <wferi@niif.hu>
Subject: Re: Netconsole and logging everything from /dev/console
Date: Thu, 30 Oct 2008 15:39:52 +0100
Message-ID: <87bpx2gn9j.fsf@tac.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Martin Michlmayr <tbm@cyrius.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tac.ki.iif.hu ([193.6.222.43]:44940 "EHLO tac.ki.iif.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755413AbYJ3Ojz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Oct 2008 10:39:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2007-11-17 Martin Michlmayr wrote:

> * Matt Mackall <mpm <at> selenic.com> [2007-11-16 12:50]:
>
>>> Do you think that would be possible?
>> 
>> It is, definitely, you just need to wire up a tty struct's write
>> method to netconsole's and add it to the console registration. But I
>> haven't had any time to work on this in a while.
>
> Where would I look for examples I could follow?

Hi,

Such feature would indeed be useful.  Did you get anywhere with it?
-- 
Thanks,
Feri.
