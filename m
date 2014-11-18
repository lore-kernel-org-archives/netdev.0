From: rapier <rapier@psc.edu>
Subject: Re: Question about Patch Submissions
Date: Tue, 18 Nov 2014 15:39:17 -0500
Message-ID: <546BAE75.7080802@psc.edu>
References: <546B9A45.9040509@psc.edu> <CAHA+R7P-G4P-AzTM248FqNEm=dcuQOB_fwdM0Us3gsQgSeY0UQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:57185 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932426AbaKRUjT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Nov 2014 15:39:19 -0500
In-Reply-To: <CAHA+R7P-G4P-AzTM248FqNEm=dcuQOB_fwdM0Us3gsQgSeY0UQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong,

Thanks for the response.

It's a pretty extensive patch set and we're trying to make sure it makes 
sense in context. It touches quite a few files and they're mostly 
interdependent. That's why we're having problems trying to figure out 
how to break this down for presentation. We can make sure each section 
of the patch applies cleanly but the entirety of the patch set would 
have to be applied for it to compile.

Chris

On 11/18/14, 3:21 PM, Cong Wang wrote:
> On Tue, Nov 18, 2014 at 11:13 AM, rapier <rapier@psc.edu> wrote:
>> I've read the documentation I've been able to find on the patch submission
>> process. I was hoping to clarify one thing though. When submitting a patch
>> that spans multiple files and functions is it better to break the submission
>> down by function or by file?
>>
>
> It depends on what you change, if your patch is trivial, say just cleaning up
> whitespaces, or a big single patch doesn't harm review, it is okay not
> to split it.
> Otherwise, probably you need to split it logically, each of which needs to at
> least compile.
>
