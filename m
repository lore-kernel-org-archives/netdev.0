From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: Re: WARNING: at net/sched/sch_generic.c:256 dev_watchdog+0x1f2/0x200()
Date: Tue, 20 Mar 2012 22:15:58 -0700
Message-ID: <4F69640E.3000505@gmail.com>
References: <20120205134050.7e135bb231b613806a2e0b70@gmail.com> <4F2F0065.9040909@lwfinger.net> <20120205222141.GA26223@electric-eye.fr.zoreil.com> <20120205145913.194746473361e324bda1eb4a@gmail.com> <CAKFRV=NghW3kokuD-VBAzVJf09r-9ePMG+L7qDYfqmuHwWo4mg@mail.gmail.com> <20120320093709.GA5058@electric-eye.fr.zoreil.com> <4F689131.2030607@gmail.com> <4F68F727.9030405@gmail.com> <20120320232700.GA21932@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:60188 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751035Ab2CUFQC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 01:16:02 -0400
Received: by obbeh20 with SMTP id eh20so464283obb.19
        for <netdev@vger.kernel.org>; Tue, 20 Mar 2012 22:16:02 -0700 (PDT)
In-Reply-To: <20120320232700.GA21932@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/20/2012 04:27 PM, Francois Romieu wrote:
> Justin P. Mattock<justinmattock@gmail.com>  :
> [...]
>> well i dont know what happened.. I suspend throughout the day
>> without any issues, but then on one wakeup everything went to crap
>> ethernet started to try and connect without any wires in.. only
>> thing I can think of is I was dongling with my phone(but the phone
>> was disconnected before suspend),which uses a different module..
>
> The MII registers read as 0xff. I'll have to figure why the
> suspend / resume cycle failed, or why it seemed to work. :o/
>

not sure why this did this, I rebooted and have suspended numerous times 
without an issue with ethernet, even retraced my steps to try and 
re-created but nothing. seems solid to me beside that hickup.

I am trying to gather any info for you, if you have any ideas on what I 
can try let me know!

Thanks for the patch and info with this.

Justin P. Mattock
