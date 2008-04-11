From: Mark Lord <lkml@rtr.ca>
Subject: Re: 2.6.25-rc8: FTP transfer errors
Date: Fri, 11 Apr 2008 10:59:57 -0400
Message-ID: <47FF7CED.9090601@rtr.ca>
References: <47FEADCB.7070104@rtr.ca> <20080410.172453.44434205.davem@davemloft.net> <47FEB062.3020003@rtr.ca> <20080410.173911.179180620.davem@davemloft.net> <47FEBDAA.7010305@rtr.ca> <Pine.LNX.4.64.0804110849520.28360@wrl-59.cs.helsinki.fi> <47FF6555.50004@rtr.ca> <20080411143537.GA27874@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?SWxwbyBKw6RydmluZW4=?= <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>, jesper.juhl@gmail.com,
	tilman@imap.cc, yoshfuji@linux-ipv6.org,
	Jeff Garzik <jeff@garzik.org>, rjw@sisk.pl,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760597AbYDKPAV@vger.kernel.org>
In-Reply-To: <20080411143537.GA27874@2ka.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> On Fri, Apr 11, 2008 at 09:19:17AM -0400, Mark Lord (lkml@rtr.ca) wrote:
>>>> Or I can ignore it, like the net developers, since I have a workaround.
>>>> And then we'll see what other apps are broken upon 2.6.25 final release.
>> That's not demanding, that's quite relaxed.  I had a good workaround,
>> and didn't really care any more at that point.  Just though it was rather
>> odd that none of the developers seemed interested in tracking it down.
>> I offered tons of help, gave it, and said I didn't have time for a full
>> bisect at that juncture.
>>
>> For that, I get repeatedly slammed by the netdev folks.
>> Even after I put aside *paid* work to submit to your demands.
>>
>> Next time around, I won't bother reporting bugs to you folks,
>> that's for damned sure.
> 
> Actually that will be the best decision from evolutional point of view. 
> 
> Bugs, which 'are thrown back to your face' like what you did with this
> one, are useless. Developers already know, that bugs exist. 
> 
> If you do not care about bug, why do you ever bothered filling it?
..

Because I care, about Linux's reputation and performance.
I care about basic networking operations, and knew that this bug
would probably affect other applications once widely deployed.

I care about Linux.  That's why.

> If you do not want to help fixing it ...

Where the hell did I *ever* say that?
I did nothing but offer help, and respond quickly.

The one thing I did not have time for initially,
was a painstaking blunt instrument binary search of
every commit since v2.6.24.

There are other ways to debug things and find the causes
quickly, with less impact upon the reporters of bugs.

The current generation of kernel "code submitters" here
seems to have never learned those.  Bummer.

Cheers
