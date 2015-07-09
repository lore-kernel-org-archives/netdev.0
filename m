From: Martin Sustrik <sustrik@250bpm.com>
Subject: Re: [PATCH v3 1/1] eventfd: implementation of EFD_MASK flag
Date: Thu, 09 Jul 2015 11:22:32 +0200
Message-ID: <c1a7500e31bbe8595f30e272e6cc9a85@imap.lucina.net>
References: <1361187290-11759-1-git-send-email-sustrik@250bpm.com>
 <559E296A.6040606@igel.co.jp>
 <8bb2fb10a310dc3e1eddb851aba93054@imap.lucina.net>
 <559E39AC.1010408@igel.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Damian Hobson-Garcia <dhobsong@igel.co.jp>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <559E39AC.1010408@igel.co.jp>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2015-07-09 11:06, Damian Hobson-Garcia wrote:
> Hi Martin,
> 
> On 2015-07-09 5:41 PM, Martin Sustrik wrote:
>> Hi Damian,
>> 
>> Yes, this patch would be geneally useful for implementing stuff in 
>> user
>> space that otherwise would have to live in kernelspace.
>> 
>> Unfortunately, I have no cycles left to pursue getting it to the
>> mainline. If you feel like you can take care of it, that would be 
>> great.
> I'll see what I can do. I'll rebase it and resubmit it.
> Unless there are major changes (which I highly doubt), I'll keep you as
> the author, if that's ok with you.

Sure. No problem.

>> 
>> I can help with the documentation, if needed.
> Thank you, that would be very much appreciated.

Ok, ping me when it's needed.

Thanks!
Martin
